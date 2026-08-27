const https = require('https');

const data = JSON.stringify({
  action: 'check_status',
  email: 'abinash818@gmail.com',
  device_id: 'test_device'
});

const options = {
  hostname: 'blueviolet-barracuda-132915.hostingersite.com',
  port: 443,
  path: '/muruga_api.php',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = https.request(options, res => {
  let responseBody = '';
  res.on('data', chunk => {
    responseBody += chunk;
  });
  res.on('end', () => {
    console.log('muruga_api.php (wrong device):', responseBody);
  });
});

req.write(data);
req.end();

const data2 = JSON.stringify({
  action: 'check_status',
  user_id: 'abinash818@gmail.com',
  email: 'abinash818@gmail.com'
});

const options2 = {
  hostname: 'blueviolet-barracuda-132915.hostingersite.com',
  port: 443,
  path: '/user_subscription_api.php',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data2.length
  }
};

const req2 = https.request(options2, res => {
  let responseBody = '';
  res.on('data', chunk => {
    responseBody += chunk;
  });
  res.on('end', () => {
    console.log('user_subscription_api.php:', responseBody);
  });
});

req2.write(data2);
req2.end();
