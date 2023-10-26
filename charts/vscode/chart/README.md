# VS Code Space

VS Code Space leverages the open-source version of [Visual Studio Code](https://github.com/microsoft/vscode) to provide a fully functional VS Code instance running inside your Kubernetes cluster. This setup provides a potent DevOps tool right within your cluster, automatically connected, and ready for use.

## Benefits

- **Versatile Platform**: Visual Studio Code is a comprehensive and versatile platform that supports a vast array of programming languages and frameworks out of the box. It is adaptable to different workflow requirements and preferences.
  
- **Pre-installed Tools**: A variety of essential development tools and SDKs are pre-installed to get you up and running immediately. This includes Docker, Kubernetes CLI, Helm Package Manager, and several others that are crucial for managing and developing in a Kubernetes environment.
  
- **Integrated Development Environment**: Having VS Code run on your cluster provides an integrated environment where you can code, build, test, and deploy applications right within the same ecosystem. This setup significantly streamlines the development workflow and improves productivity.
  
- **Cluster Admin Level Access**: The VS Code instance runs as root, ensuring that cluster administrators have all the necessary privileges to manage and troubleshoot the cluster effectively.

## Use Cases

- **Real-time Monitoring and Troubleshooting**: Quickly diagnose and fix issues within your Kubernetes cluster without the need to switch between multiple tools and platforms.
  
- **Continuous Development and Integration**: Seamlessly code and deploy applications within your cluster, enjoying a smooth CI/CD pipeline right from your VS Code instance.
  
- **Cluster Management**: Manage your Kubernetes cluster configurations, deployments, and services conveniently from a centralized VS Code instance.
  
- **Collaborative Development**: Although not recommended for multiple developers to share the same instance simultaneously, it's possible to have a shared environment where different developers work at different times.

## Installed SDKs & Tools

- [Docker](https://docs.docker.com/engine/reference/commandline/cli/)
- [Kubernetes](https://kubectl.docs.kubernetes.io/)
- [Helm Package Manager](https://helm.sh/)
- [OpenJDK](https://openjdk.java.net/)
- [.NET Core](https://dotnet.microsoft.com/)
- [Node.js](https://nodejs.org/en/about/)
- [Python](https://www.python.org/about/)
- [Go](https://golang.org/)

## Installed Extensions

- [Go](https://marketplace.visualstudio.com/items?itemName=golang.Go)
- [C#](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)
- [Java](https://marketplace.visualstudio.com/items?itemName=redhat.java)
- [Java Debugger](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-debug)
- [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [Kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
- [GitHub Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme)
- [Browser Preview](https://marketplace.visualstudio.com/items?itemName=auchenberg.vscode-browser-preview)
