import ch.psi.jcae.*

% Use of SLS configuration
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'sls-cagw')
properties.setProperty('EPICS_CA_SERVER_PORT', '5062')

context = Context(properties)
channel = context.createChannel(ChannelDescriptor('double', 'YOUR-CHANNEL'))

print channel.get()

channel.close()
context.close()
