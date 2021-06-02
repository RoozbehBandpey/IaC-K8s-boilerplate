# First Principles

This section will lay down the first principles around which we should visualize infrastructure itself.

## Standards, Abstractions and Encapsulation
Infrastructure should be seen as nothing but a “Black Box” which is decomposable into multiple different black boxes as needed with each black box fulfilling a separate responsibility.

## Automate Everything
Every operation with the infrastructure should be automated to the best extent possible. This can be anything which is part of the process including healing, recovery, failover, deployments, migrations, upgrades, log shipping and more. If you find yourself doing something repeatedly, then consider automating since it can save countless hours of time in the future and can also prevent possible human errors in doing things manually.

## Extendibility
Infrastructure should also be extendible by anyone as needed via something like APIs which allows users to build on top of these components as specific to their use case.

This is important because not every use case in the world can be natively addressed and adding them all to the core would most often seem nonsensical. Keeping this in mind, a plugin driven approach is often empowering to the entire ecosystem in general.

## Environmental Consistency
While infrastructure can typically vary between different environments be it development, staging or production, across multiple different deployments the experience of the user should be consistent across all these different environments abstracting the various differences between them typically as adapters.


## Packaging and Release
This mandates the need for all components in the infrastructure to maintain its own versioned packaging and release mechanism allowing a consistent and clear upgrade path for every component.


## Modularity, Single Responsibility & Incremental Scalability
Infrastructure should be modular with its own set of APIs each fulfilling a single responsibility which are then orchestrated together to fulfill the complete use case. This not only reduces the possibility of errors creeping in with each module handling its own release cycle, but it also allows for things like incremental adoption and scalability from small to large projects just using the modules which they really need to satisfy their use case.

This also allows for scalability at the module level depending on your use case.

## Administration
Users must be able to easily monitor and administer any of these components as needed optionally abstracting the complexity of what happens underneath offering a way to respond quickly in the advent of issues which can typically crop up in any part of the infrastructure and also allow for use cases like cost optimization where infrastructure can be effectively utilized where possible and security where the path of communication between all components is better visible for the administrator to enable them to secure it properly as needed.
## Declarative and Self-Documenting Infrastructure as Code
We should try to architect for change and this is where Infrastructure as code really helps us to well document and orchestrate all the different states of the infrastructure over time declaratively, version control them and do it all in such a way that there is also a path to roll back to a previous state where needed.

This also paves way for collaboration, reviews, automation and testing where the changes between 2 different states can be well tested in different environments and then consistently rolled out to multiple environments as needed.
## Sensible Management of State
The problem is not in the state, but in managing it properly. Avoiding state is often difficult especially given the dynamic nature of applications today.

Maintaining state improperly can cause a lot of issues in scaling your applications and the infrastructure that goes with it. So, rather than spreading the state everywhere, it is often sensible to manage the state properly and in isolation so that the rest of the application can work and scale independently of the stateful services while the stateful services can follow their own path to scalability decoupling both worlds from each other.
## Faster Inner Dev Loop and Agility
While you may maintain a complex infrastructure and a rollout process for your use case, the same complexity should not be exposed during the development phase. Rather the development experience should be such a way that the infrastructure completely fades behind the scenes, and the developers just focus on getting quick feedback for all the changes they make.

This can involve a lot of techniques like using sync instead of rebuilds, allowing hybrid development allowing developers to just host a portion of the infrastructure they work on locally leaving the rest in the target environment, custom network proxying, better IDE integration and more all done to speed up the inner dev loop and agility of development.
## No single point of failure
For an infrastructure to be reliable, there should typically be no single point of failure, otherwise called highly available systems. This calls for decentralization of responsibilities and also to have things like redundancies and failovers where needed. But it is also important to consider that a 99.99% uptime might not be the call for every use case and hence different use cases call for different levels of redundancies and failover mechanisms making this decision completely dependent on the use case.

It is always better to design simple systems at start and incrementally scalable systems over time as the need arises. So, building highly scalable systems are a journey and not the destination by itself since more decentralization creates more complexity.
## Support for Seamless Collaboration
Products are often built with the effort of multiple members of a team and the same goes for infrastructure and the applications running on it as well.

Keeping this in mind, it is important to support seamless ways to collaborate while working on the infrastructure facilitating parallel changes from multiple people, allowing the ability to research and experiment with any part of the infrastructure in an isolated context or sandbox without affecting the others and also the ability to share or package portions of infrastructure as needed facilitating seamless collaboration between different members and this should be done so keeping security in mind allowing only authorized personnel to make changes as needed but do so in a way without creating friction amongst users.
## Zero Trust Security
While designing always answer this question “If this gets compromised, this is what will happen and this is how I will respond” and this is where Zero Trust Security really plays a major role where you never trust anything or anyone at anytime.

This can involve anything from reviewing the access policies, reviewing the network paths, encrypting data or other PII, separating data into multiple tenants, scanning the images, reviewing the underlying infrastructure for security concerns, separating the boundary of attacks or anything similar which can either prevent or reduce the impact of the attack.
## Infrastructure should be dumb
Every module should have a single responsibility and this should be in such a way that there is always a cause to a change in the infrastructure.

For instance, if your infrastructure has to auto scale, it is often better to do it without introducing too much complexity to the infrastructure or its controllers itself. Rather, try to dumb it down as much as possible and use some sensible criteria either from experience or from the historical data to take decisions on the scale either manually or automatically depending on how often such changes are needed. Asking your infrastructure to do too much for you will just raise the complexity. Or if you are indeed looking to create a smart infrastructure system, try to spread the complexity rather than keeping it locked into a single component.
## Discoverability
It is very important to have discoverability in mind when designing these systems since they might often need to work together to complete a specific task which can happen only if they are discoverable as and when needed.

While the mechanism of discoverability itself boils down to your use case, the one thing to keep in mind is that it is better to distribute discoverability since we don’t want a single point of failure and also the fact that it should be easy to understand the various calls and the network traffic well without introducing too much complexity even as the number of components and services increase over time.
## Eventual consistency
Distributed systems and infrastructure are always eventually consistent considering the various factors like network latencies, bandwidth, throughput, I/O speeds and so on. So, rather than avoiding this fact, designing a system to support eventual consistency is always better since it will help you to better handle failures or data lags whenever it occurs.

While there are mechanisms like distributed transactions in place to handle this problem, even such solutions are nothing but eventual consistencies with abstractions on top. 
## Testability
Testability becomes a really important part especially when you want a high degree of stability and automation in place with the constant influx of change you might have in the future. Every part of the infrastructure should be testable in isolation and also as a group to bring about a greater degree of confidence the users would have on the underlying infrastructure.
This can be anything from testing the various integration points between the infrastructure to testing the logic within giving a complete picture of what went or can go wrong.
## Sensible defaults
While we discuss all of these principles, effort must also be made to provide sensible defaults wherever possible allowing the users to incrementally adopt, change or scale as needed. Sensible defaults includes making every piece of infrastructure secure by default, allow basic functionalities like monitoring, logging, backups, failover, etc. without having to manually configure it to work.
This can prevent a lot of issues which just happen due to the lack of knowledge users might have while working on a part of infrastructure, dumb it down for new comers and also help users to start any project as quickly as possible without going through too much of configuration to start working on something.
## Seamless upgrades, updates, maintenance and failovers
While cloud providers do offer an SLA for the deployments when paid, this should not be a feature but rather the default. Upgrades, updates, failovers and maintenance should happen seamlessly without affecting the workloads running on the infrastructure. And even in case of failures, there should be a way to still serve sensible traffic to customers as and when needed avoiding possible downtime.
All this can happen only if a possible failure is detected as early as possible and effort is made to switch over to healthy traffic and deployment wherever available. To the same effect, proper health checks should be in place to identify and handle failures if any in any part of the infrastructure and even handle upgrades seamlessly as they occur.
## Fail Quickly and Respond Sensibly
It is not practically possible to have a 100% uptime for every portion of your infrastructure. Rather, the components should fail quickly whenever there are issues and respond sensibly whenever possible. It is often better to let failures to happen rather than suppressing them which might create a catastrophe at a future point of time.