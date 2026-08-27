import sys

def main():
    file_path = 'lib/screens/input_screen.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        old_str = r'''  Future<void> _generatePDF() async {
    if (_formKey.currentState!.validate()) {'''

        new_str = r'''  Future<void> _generatePDF() async {
    if (_formKey.currentState!.validate()) {
      final Map? args = ModalRoute.of(context)?.settings.arguments as Map?;
      final bool isKp = args?['isKp'] == true;'''

        content = content.replace(old_str, new_str)

        old_pdf_call = r'''        if (kIsWeb) {
          OnePagePdfService.showHtmlReport(
            name: _nameController.text,
            gender: _selectedGender,
            results: results,
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
          
          final bytes = await OnePagePdfService.generate(
            name: _nameController.text,
            gender: _selectedGender,
            results: results,
          );
          
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                pdfBytes: bytes,
                fileName: _nameController.text,
              ),
            ),
          );
        }'''

        new_pdf_call = r'''        if (kIsWeb) {
          if (isKp) {
            KpOnePagePdfService.showHtmlReport(
              name: _nameController.text,
              gender: _selectedGender,
              results: results,
            );
          } else {
            OnePagePdfService.showHtmlReport(
              name: _nameController.text,
              gender: _selectedGender,
              results: results,
            );
          }
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
          
          final bytes = isKp 
              ? await KpOnePagePdfService.generate(
                  name: _nameController.text,
                  gender: _selectedGender,
                  results: results,
                )
              : await OnePagePdfService.generate(
                  name: _nameController.text,
                  gender: _selectedGender,
                  results: results,
                );
          
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                pdfBytes: bytes,
                fileName: _nameController.text,
              ),
            ),
          );
        }'''

        content = content.replace(old_pdf_call, new_pdf_call)
        
        # Ensure KpOnePagePdfService is imported
        import_stmt = "import '../services/kp_one_page_pdf_service.dart';"
        if import_stmt not in content:
            content = content.replace("import '../services/one_page_pdf_service.dart';", "import '../services/one_page_pdf_service.dart';\n" + import_stmt)

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
        print("Updated input_screen.dart")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()
