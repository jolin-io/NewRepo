# JolinWorkspaceTemplate

Template to quickly setup a Jolin Low-Code Workspace


## How to work with Jolin Workspace

To use Jolin Workspace, you don't need to know much about programming. Everything is
simplified into one central web interface which allows you to interactively explore your
data and see analysis results immediately.

In addition to such interactive web experiments, Jolin Workspace gives you
<!-- TODO make this three blobs next to each other -->
- realtime collaboration during development
- continuous integration (CI), with automated tests generated from your web experiments
- continuous deployment (CD) to kubernetes (Big Data support coming soon)

CICD is super simple with Jolin Workspace:
1. After doing your experiments you inform your colleagues about your changes from within the web experiment.
2. It will open a github pull-request, which is essentially a standardized and easy to
    use web interface for discussing changes to versioned software.
3. This very discussion page will automatically run tests for you, generated from your web experiments.
4. If all is fine, then the changes can be approved on that discussion page. This will
    automatically trigger the deployment process. A few minutes later, your dashboards
    or processes are live! 🤩
