
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const braintree = require("braintree");

admin.initializeApp();

// Initialize the Braintree gateway with your API keys
const gateway = braintree.connect({
  environment: braintree.Environment.Sandbox, // Use Sandbox for testing
  merchantId: "4thxgch2r8k799n2",
  publicKey: "zvy6mxcbw5wmhk68",
  privateKey: "f9ae3d4daf257863517d9d0472340ac5",
});

// Firebase function to generate client token
exports.getClientToken = functions.https.onRequest((req, res) => {
  gateway.clientToken.generate({}, (err, response) => {
    if (err) {
      res.status(500).send({error: "Unable to generate client token"});
    } else {
      res.status(200).send({clientToken: response.clientToken});
    }
  });
});

