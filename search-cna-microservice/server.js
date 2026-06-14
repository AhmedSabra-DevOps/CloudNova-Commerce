const axios = require("axios");
const express = require("express");

const app = express();

app.use(express.json());

const PORT = process.env.PORT || 4000;
const ELASTIC_URL = process.env.ELASTIC_URL || "http://search-engine:9200";
const INDEX_NAME = process.env.INDEX_NAME || "search";

console.log("Search service running on port", PORT);
console.log("Elasticsearch URL:", ELASTIC_URL);
console.log("Elasticsearch Index:", INDEX_NAME);

app.get("/health", (req, res) => {
  res.json({ status: "OK" });
});

app.get("/search", async (req, res) => {
  try {
    const query = (req.query.q || "").trim();

    if (!query) {
      return res.json({
        took: 0,
        hits: {
          total: { value: 0 },
          hits: []
        }
      });
    }

    const response = await axios.post(`${ELASTIC_URL}/${INDEX_NAME}/_search`, {
      size: 50,
      query: {
        bool: {
          should: [
            {
              multi_match: {
                query,
                fields: [
                  "title^4",
                  "name^4",
                  "category^3",
                  "description^2"
                ],
                fuzziness: "AUTO"
              }
            },
            {
              query_string: {
                query: `*${query}*`,
                fields: [
                  "title",
                  "name",
                  "category",
                  "description"
                ]
              }
            }
          ],
          minimum_should_match: 1
        }
      }
    });

    res.json(response.data);
  } catch (err) {
    console.log("ERROR:", err.response?.data || err.message);

    res.status(500).json({
      error: "Search failed",
      details: err.response?.data || err.message
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
