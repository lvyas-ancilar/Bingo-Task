const axios = require('axios');

const getLatestPR = async (repoOwner, repoName) => {
  try {
    const response = await axios.get(`https://api.github.com/repos/${repoOwner}/${repoName}/pulls?state=all`);
    const latestPR = response.data[0];
    return latestPR;
  } catch (error) {
    console.error(error);
  }
};

module.exports = getLatestPR;