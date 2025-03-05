import bodyParser from "body-parser";
import express from "express";
import { createJob, getStatus } from "./controllers/jobsController";
import { processNextJob } from "./domain/jobService";

const app = express();
const PORT = 8000;

app.use(bodyParser.json());

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

app.post("/jobs", async (req, res) => createJob(req, res));

app.get("/jobs/:id/status", async (req, res) => getStatus(req, res));

app.listen(PORT, () => {
  console.log(`Running at http://localhost:${PORT}`);
});

setInterval(processNextJob, 2000);
