# Integration with IDE #

## Working in NetBeans ##

To run project tests using yUnit test runner modify command line for running you test project (File -> Project properties -> Run -> Run command). You may set something like that:
lua -l yunit -e 'run(${OUTPUT\_PATH})'

But you must to use not 'Run Main Project', but 'Debug Main Project' to see normal output messages, instead of SegFault error