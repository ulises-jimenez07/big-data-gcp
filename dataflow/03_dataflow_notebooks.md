# Dataflow: Creating a Notebook in GCP Console

For interactive development of Apache Beam pipelines, Google Cloud offers **Vertex AI Workbench** (formerly known as Dataflow Notebooks). These are managed JupyterLab instances pre-configured with Beam libraries.

## 1. Enable Required APIs

Before creating a notebook, ensure the following APIs are enabled in your GCP project:
1.  **Dataflow API**
2.  **Compute Engine API**
3.  **Notebooks API** (Vertex AI)

You can do this via the [GCP Console API Library](https://console.cloud.google.com/apis/library).

---

## 2. Create a Notebook Instance

Follow these steps to set up your environment:

1.  In the GCP Console, search for **Vertex AI** and select **Workbench**.
2.  Click on **User-Managed Notebooks**.
3.  Click **+ NEW NOTEBOOK**.
4.  Select **Apache Beam** (or **Python 3** if Apache Beam is not explicitly listed as a standalone image, but usually there is a specialized Beam image).
5.  **Configure the Instance**:
    - **Name**: `beam-tutorial-notebook`
    - **Region/Zone**: Choose a region close to your data (e.g., `us-central1`).
    - **Machine Type**: `e2-standard-4` is usually sufficient for testing.
6.  Click **CREATE**.

It will take a few minutes for the instance to be provisioned.

---

## 3. Launching JupyterLab

1.  Once the instance status is "Running," click **OPEN JUPYTERLAB**.
2.  This opens a new tab with a full Jupyter environment.
3.  Create a new notebook by clicking the **Python 3** icon under "Notebook."

---

## 4. Why use Notebooks for Dataflow?

- **Interactive Development**: You can run small chunks of your pipeline using the `DirectRunner` to see immediate results.
- **Graph Visualization**: Beam notebooks can render the pipeline graph, making it easier to debug complex logic.
- **Pre-installed Dependencies**: No need to `pip install` basic Beam or GCP libraries; they are already there.
- **Seamless Dataflow Deployment**: You can test locally in the cell and then submit the job to the real Dataflow service just by changing one configuration parameter.

In the next tutorial, we will write our first end-to-end pipeline using this notebook.
