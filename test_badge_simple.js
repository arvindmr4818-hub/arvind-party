const axios = require('axios');

// Test the badge system
async function testBadgeSystem() {
  try {
    console.log('Testing Badge System...');

    // Test the health endpoint
    const healthResponse = await axios.get('http://localhost:5000/health');
    console.log('Health check:', healthResponse.data);

    // Test the root endpoint
    const rootResponse = await axios.get('http://localhost:5000/');
    console.log('Root endpoint:', rootResponse.data);

    console.log('✅ Server is running!');
  } catch (error) {
    console.error('Error testing badge system:', error.message);
  }
}

// Run the test
testBadgeSystem();
</content>
</invoke>
