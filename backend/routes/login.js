require('dotenv').config();

const Token = require('../models/token');
const express = require('express');
const axios = require('axios');
require('dotenv').config();

const router = express.Router();

const instanceUrl = process.env.INSTANCE_URL; // ✅ Fix here
const clientId = process.env.CLIENT_ID;
const redirectUri = process.env.REDIRECT_URI;

//redirects to login mastodon login page
router.get('/auth/redirect', (req, res) => {

    const redirectUrl = `${instanceUrl}/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code&scope=read+write+follow`;

    res.redirect(redirectUrl);
});

//callback that will take in the code and redirect you back into the app
router.get('auth/callback', (req,res) => {

const code = req.params.code;

if(!code){
  return res.status(400).send('Missing code');
}

  const flutterRedirect = `myapp://auth/callback?code=${code}`;
  res.redirect(flutterRedirect);

})

//takes in credentials 
router.post('/auth/token', async (req, res) => {
  const code = req.body.code;

  try {
    const response = await axios.post('https://mastodon.social/oauth/token', null, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      params: {
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: process.env.REDIRECT_URI,
      },
    });

    //stores the access token 
    const accessToken = response.data.access_token;
    //console.log("Access token received:", accessToken);
    
    //fetches username
    const userResponse = await axios.get('https://mastodon.social/api/v1/accounts/verify_credentials', {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    const username = response.data.username;
    
    //no duplicate entries
    try{
    await Token.create({
      token: accessToken,
      username: username,
      createdAt: new Date(),
    });
  } catch (err){
    if(err = 1100){
      console.error("Duplicate Entry");
      return res.status(400).json({error : "User already exists"});
    }
    throw err;
  }

    res.json({user : accessToken, username}); // return the token back to Flutter if needed
  } catch (error) {
    console.error('Token exchange failed:', error.response?.data || error.message);
    res.status(500).json({ error: 'Token exchange failed' });
  }
});

//fetch token associated by the user

router.get('auth/token/username:', async (req, sec) => {

  try{

    const tokenDoc = await Token.findOne({username: req.params.user});

    if(!tokenDoc){
      res.status(400).json({error: "No username combined"});
    }

    res.json({accessToken: tokenDoc.accessToken});
  }catch(err){
    console.error("erorr fetching token", err)
    res.status(500).json({ error: 'Server error' });
  }

});





module.exports = router;
