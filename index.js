require("dotenv").config();

const express = require("express");
const app = express();

app.get("/", (request, response) => {
  response.send("Salut les Onigiri");
});

app.listen(process.env.PORT);
