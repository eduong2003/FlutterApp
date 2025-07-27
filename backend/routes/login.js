const express = require('express');
const axios = require('axios');
require('dotenv').config();

const router = express.Router();

router.get('/auth/redirect', (req, res) => {

    const redirectUrl = `https://mastodon.social/oauth/authorize?client_id=${process.env.CLIENT_ID}&redirect_uri=${process.env.REDIRECT_URI}&response_type=code&scope=read+write+follow`;

    res.redirect(redirectUrl);
});


module.exports = router;
