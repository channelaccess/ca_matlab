# Overview
The __ca_matlab__ package provides an easy to use Channel Access library for Matlab.
This document describes how to interface Epics via Channel Access within Matlab. The

The latest released of this package can be downloaded [here](https://github.com/channelaccess/ca_matlab/releases).

The *prerequisites* for this package is *Matlab2015a* or later. There are absolutely no other dependencies beside that (just include the Jar as described below).


# Configuration

To be able to use the library you have two options, a dynamic and a static one. The difference between the two options is that
with dynamic you will *bundle* the library with your Matlab code, with the static one you will set the library one time globally
for your Matlab instance.

If you are unsure which one to use, we strongly suggest to use the dynamic approach!

## Dynamic

To get started with the library just copy the downloaded jar into the folder holding your Matlab code file. At the top of your .m file just add following line:

```
javaaddpath('ca_matlab-1.0.0.jar')
```

In scripts that get executed several times in the same workspace use following construct to get rid of the Matlab warnings regarding re-adding to the classpath:

```matlab
if not(exist('java_classpath_set'))
    javaaddpath('ca_matlab-1.0.0.jar')
    java_classpath_set=1
end
```

In more complex Matlab projects you might not want to have the library in the same place as your matlab files but on a sub/parent-folder. In this case use relative paths to refer to the library.

```matlab
javaaddpath('../ca_matlab-1.0.0.jar')
```

For Windows users, keep in mind to use backslashes in the path `\` !


## Static
To be able to use the package, include the _full qualified path_ of the jar in the *javaclasspath.txt* within the Matlab home folder (ideally also copy the jar into this directory). For example:

```
/Users/ebner/Documents/MATLAB/ca_matlab-1.0.0.jar
```

After creating/altering the file(s) *javaclasspath.txt* you need to restart Matlab.



# Usage

## Quick Start

After loading the required jar (see Overview above) channels can be created and be read/written as follows:

```Matlab
import ch.psi.jcae.*
context = Context()
channel = context.createChannel(ChannelDescriptor('double', 'ARIDI-PCT:CURRENT'))
channel.get()
channel.close()
context.close()
```

## Context
Before being able to create channels there need to be a context. For normal setups, ideally there should be only one context per Matlab application.

```Matlab
import ch.psi.jcae.*
context = Context()
```

If needed (i.e. to set the EPICS_CA_ADDR_LIST or EPICS_CA_MAX_ARRAY_BYTES) the context can be configured via properties.

```Matlab
import ch.psi.jcae.*
properties = java.lang.Properties()
properties.setProperty("EPICS_CA_ADDR_LIST", "10.0.0.255");

context = Context(properties)
```

Currently following properties are supported:

|Name|Description|
|----|----|
|EPICS_CA_ADDR_LIST||
|EPICS_CA_AUTO_ADDR_LIS||
|EPICS_CA_SERVER_PORT||
|EPICS_CA_MAX_ARRAY_BYTES||

_Note:_ For Paul Scherrer Institute users there is a list of example configurations for accessing the different facilities in [Environments.md](Environments.md).



The context need to be closed at the end of the application via

```Matlab
context.close()
```

## Channel
To create a channel use the createChannel function of the context. The functions argument is a so called ChannelDescriptor which describes the desired channel, i.e. name, type, monitored (whether the channel object should be constantly monitoring the channel) as well as size (in case of array).

Here are some examples on how to create channels:

```Matlab
% Create double channel
channel = context.createChannel(ChannelDescriptor('double', 'ARIDI-PCT:CURRENT'))
% Create monitored double channel
channel = context.createChannel(ChannelDescriptor('double', 'ARIDI-PCT:CURRENT', true))


% Create a channel for a double waveform/array - the size will be determined by the channel
channel = context.createChannel(ChannelDescriptor('double[]', 'ARIDI-PCT:CURRENT', true))
% Create a channel for a double waveform/array of specific size 10
% If the actual channel array is bigger you specify you would only retrieve the first 10 elements
channel = context.createChannel(ChannelDescriptor('double[]', 'ARIDI-PCT:CURRENT', true, java.lang.Integer(10)))
```

Supported types are: `double`, `integer`, `short`, `float`, `byte`, `boolean`, `string` and the respective array forms `double[]`, `integer[]`, `int[]`, `short[]`, `float[]`, `byte[]`, `boolean[]`, `string[]` .

After creating a channel you are able to get and put values via the `get()` and `put(value)` methods. _Note_, if you created a channel with the monitored flag set true `get()` will not reach for the network to get the latest value of the channel but returns the latest update by a channel monitor.
If you require to explicitly fetch the value over the network use `get(true)` (this should only be rare cases as most of the time its enough to get the cached value)

_Note_, a polling loop within your Matlab application on a channel created with the monitored flag set *true* is perfectly fine and does not induce any load on the network.

To put a value in a fire and forget style use `putNoWait(value)`. This method will put the value change request on the network but does not wait for any kind of acknowledgement.

```Matlab
channel.get()
channel.put(10.0)
channel.putNoWait(10.0)
```

Beside the synchronous (i.e. blocking until the operation is done) versions of `get()` and `put(value)` there are also asynchronous calls. They are named `getAsync()` and `putAsync(value)`. Both functions immediately return with a handle for the operation, i.e. a so called Future. The Future can be used to wait at any location in the script to wait for the completion of the operation and retrieve the final value of the channel.

Example asynchronous get:

```Matlab
future = channel.getAsync()
future_2 = channel_2.getAsync()

% do something different ...
do_something()
% ... or simply sleep ...
pause(10)
% ... or simply do nothing ...

value_channel = future.get()
value_channel_2 = future_2.get()
```

Example asynchronous put:

```Matlab
future = channel.putAsync(value_1) % this could, for example start some move of a motor ...
future_2 = channel_2.putAsync(value_2)

% do something different ...
do_something()
% ... or simply sleep ...
pause(10)
% ... or simply do nothing ...

future.get() % this will return the set value, i.e. value_1
future_2.get() % this will return the set value, i.e. value_2
```

Waiting for channels to reach a certain value can be done as follows:

```matlab
// Wait without timeout (i.e. forever)
channel.waitForValue('world')

// Wait with timeout
waitHandle = channel.waitForValueAsync('world').get(Long(10), java.util.concurrent.TimeUnit.SECONDS)
```

If you want to do stuff while waiting you can implement a busy loop like this:

```matlab
waitfuture = channel.waitForValueAsync('world')
while not(waitfuture.isDone())
    % do something
end
```


After you are done working with a channel close the channel via

```Matlab
channel.close()
```
