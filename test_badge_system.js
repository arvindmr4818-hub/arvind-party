const axios = require('axios');

// Test the badge system
async function testBadgeSystem() {
  try {
    console.log('Testing Badge System...');

    // Test the user center endpoint
    const response = await axios.get('http://localhost:5000/api/users/center', {
      headers: {
        'Authorization': 'Bearer test-token'
      }
    });

    console.log('User Center Response:', response.data);

    if (response.data.badges && response.data.badges.length > 0) {
      console.log('✅ Badge system is working!');
      console.log('Badges:', response.data.badges);
    } else {
      console.log('❌ No badges found in response');
    }
  } catch (error) {
    console.error('Error testing badge system:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
      console.error('Response status:', error.response.status);
    }
  }
}

// Run the test
testBadgeSystem();