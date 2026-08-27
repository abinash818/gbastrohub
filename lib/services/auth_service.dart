import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '955705451742-8k83cke1kiqqhqp22gtqau6l3gb1ll5v.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Windows/Desktop custom Google OAuth implementation
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        try {
          // Launch local server
          final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
          final clientId = '955705451742-8k83cke1kiqqhqp22gtqau6l3gb1ll5v.apps.googleusercontent.com';
          final redirectUri = 'http://localhost:8080'; // Must be authorized in Google Cloud Console
          
          final url = Uri.parse('https://accounts.google.com/o/oauth2/v2/auth'
              '?client_id=$clientId'
              '&redirect_uri=$redirectUri'
              '&response_type=token id_token'
              '&scope=email profile'
              '&nonce=random_nonce');

          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            server.close();
            throw Exception("Could not launch default browser");
          }

          final completer = Completer<UserCredential?>();
          
          server.listen((HttpRequest request) async {
            if (request.uri.path == '/') {
              // The tokens are in the hash fragment which the server can't see directly.
              // We serve a tiny HTML page that extracts the hash and sends it back to /token.
              request.response
                ..headers.contentType = ContentType.html
                ..write('''
                  <html>
                    <body style="font-family: sans-serif; text-align: center; margin-top: 50px;">
                      <h2 id="msg">Logging you in... Please wait.</h2>
                      <script>
                        if (window.location.hash) {
                          fetch('/token?' + window.location.hash.substring(1))
                            .then(() => {
                              document.getElementById("msg").innerHTML = "Login Successful! <br><br> You can close this window and return to the app.";
                            });
                        } else {
                          document.getElementById("msg").innerHTML = "Login Failed! No authorization token received.";
                        }
                      </script>
                    </body>
                  </html>
                ''');
              await request.response.close();
            } else if (request.uri.path == '/token') {
              final params = request.uri.queryParameters;
              final accessToken = params['access_token'];
              final idToken = params['id_token'];
              
              request.response
                ..headers.contentType = ContentType.html
                ..write('OK');
              await request.response.close();
              
              if (accessToken != null && idToken != null) {
                final credential = GoogleAuthProvider.credential(
                  accessToken: accessToken,
                  idToken: idToken,
                );
                try {
                  final userCred = await _auth.signInWithCredential(credential);
                  completer.complete(userCred);
                } catch(e) {
                  completer.completeError(e);
                }
              } else {
                completer.complete(null);
              }
              server.close();
            }
          });
          
          // Timeout after 3 minutes
          final userCred = await completer.future.timeout(const Duration(minutes: 3), onTimeout: () {
            server.close();
            return null;
          });
          return userCred?.user;
        } catch (e) {
          print('Windows Google Auth failed: $e');
          rethrow;
        }
      }

      // Mobile (Android/iOS): use the google_sign_in plugin
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In: User cancelled.');
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('Google Sign-In successful for: ${userCredential.user?.email}');
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save credentials for Windows auto-login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Email: $e');
      rethrow;
    }
  }

  // Register with Email and Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save credentials for Windows auto-login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      
      return userCredential.user;
    } catch (e) {
      print('Error registering with Email: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    
    // Clear saved credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  // Auto Login fallback for Windows (Email/Password)
  Future<User?> autoLoginWindows() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    
    if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
      try {
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
