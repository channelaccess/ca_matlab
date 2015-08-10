# Overview
The __ca_matlab__ package provides an easy to use Channel Access library for Matlab. It is cross platform and runs on all major operating systems - Linux, Windows, Mac OS X.

The latest release of this package can be downloaded [here](https://github.com/channelaccess/ca_matlab/releases).

The *prerequisites* for this package is *Matlab2015a* or later. There are no other dependencies (just include the Jar as described below).


# Configuration

There are two options to use the library, a dynamic and a static one. With the dynamic option you will *bundle* the library with your Matlab code whereas with the static option you will set the library one time globally for your Matlab instance.

__We strongly suggest to use the dynamic approach!__

## Dynamic

To get started with the library:
* Copy the downloaded jar into the folder holding your Matlab code file.
* At the top of your .m file add following line (remember to change the version to the actual one).

```matlab
javaaddpath('ca_matlab-1.0.0.jar')
```

In scripts that get executed several times in the same workspace:
* Use following construct to get rid of the Matlab warnings regarding re-adding to the classpath.

```matlab
if not(exist('java_classpath_set'))
    javaaddpath('ca_matlab-1.0.0.jar')
    java_classpath_set = 1;
end
```

In more complex Matlab projects you might want to have the library in a sub/parent-folder. In this case use relative paths to refer to the library.

```matlab
javaaddpath('../ca_matlab-1.0.0.jar')
```

For Windows users, keep in mind to use backslashes ( __\__ ) !


## Static
Include the _full qualified path_ of the jar in the *javaclasspath.txt* within the Matlab home folder (ideally also copy the jar into this directory). For example:

```
/Users/ebner/Documents/MATLAB/ca_matlab-1.0.0.jar
```

After creating/altering the file *javaclasspath.txt* you need to restart Matlab.



# Usage

## Quick Start

After loading the required jar, channels can be created and be read/written as follows:

```Matlab
import ch.psi.jcae.*
context = Context();
channel = Channels.create(context, ChannelDescriptor('double', 'ARIDI-PCT:CURRENT'));
channel.get()
channel.put(10.1);
channel.close();
context.close();
```

## Context
A context is necessary to create channels. Ideally, there should be one context per Matlab application only.

```Matlab
import ch.psi.jcae.*
context = Context();
```

It is also possible to configure the context via properties (i.e. to set the EPICS_CA_ADDR_LIST or EPICS_CA_MAX_ARRAY_BYTES).

```Matlab
import ch.psi.jcae.*
properties = java.util.Properties();
properties.setProperty('EPICS_CA_ADDR_LIST', '10.0.0.255');

context = Context(properties);
```

Currently following properties are supported:

|Name|Description|
|----|----|
|EPICS_CA_ADDR_LIST|Address list to search channel on|
|EPICS_CA_AUTO_ADDR_LIST|Automatically create address list|
|EPICS_CA_SERVER_PORT|Port of the channel access server|
|EPICS_CA_MAX_ARRAY_BYTES|Maximum number of bytes for an array/waveform|

__Note:__ For Paul Scherrer Institute users there is a list of example configurations for accessing the different facilities in [Environments.md](Environments.md).



The context needs to be closed at the end of the application via

```Matlab
context.close();
```

## Channel
To create a channel use the create function of the Channels utility class. The function's argument is a so called ChannelDescriptor which describes the desired channel, i.e. name, type, monitored (whether the channel object should be constantly monitoring the channel) as well as size (in case of array).

Here are some examples on how to create channels:

```Matlab
% Create double channel
channel = Channels.create(context, ChannelDescriptor('double', 'ARIDI-PCT:CURRENT'));
% Create monitored double channel
channel = Channels.create(context, ChannelDescriptor('double', 'ARIDI-PCT:CURRENT', true));


% Create a channel for a double waveform/array - the size will be determined by the channel
channel = Channels.create(context, ChannelDescriptor('double[]', 'ARIDI-PCT:CURRENT', true));
% Create a channel for a double waveform/array of specific size 10
% If the actual channel array is bigger you specify you would only retrieve the first 10 elements
channel = Channels.create(context, ChannelDescriptor('double[]', 'ARIDI-PCT:CURRENT', true, java.lang.Integer(10)));
```

Supported types are: `double`, `integer`, `short`, `float`, `byte`, `boolean`, `string` and the respective array forms `double[]`, `integer[]`, `int[]`, `short[]`, `float[]`, `byte[]`, `boolean[]`, `string[]` .

After creating a channel you are able to get and put values via the `get()` and `put(value)` methods.

__Note__: If you created a channel with the monitored flag set to *true*, `get()` does not access the network to get the latest value of the channel but returns the latest update by a channel monitor.
If you require to explicitly fetch the value over the network use `get(true)` (this should be rarely used as most of the time its enough to get the cached value)

__Note__: A polling loop within your Matlab application on a channel created with the monitored flag set to *true* is perfectly fine as it does not induce any load on the network.

To put a value in a fire and forget style use `putNoWait(value)`. This method will put the change request on the network but does not wait for any kind of acknowledgement.

```Matlab
value = channel.get();
channel.put(10.0);
channel.putNoWait(10.0);
```

Beside the synchronous (i.e. blocking until the operation is done) versions of `get()` and `put(value)` there are also asynchronous calls. They are named `getAsync()` and `putAsync(value)`. Both functions immediately return with a handle for the operation, i.e. a so called Future. This Future can be used to wait at any location in the script for the completion of the operation and retrieve the final value of the channel.

Example asynchronous get:

```Matlab
future = channel.getAsync();
future_2 = channel_2.getAsync();

% do something different ...
do_something();
% ... or simply sleep ...
pause(10);
% ... or simply do nothing ...

value_channel = future.get();
value_channel_2 = future_2.get();
```

Example asynchronous put:

```Matlab
future = channel.putAsync(value_1); % this could, for example start some move of a motor ...
future_2 = channel_2.putAsync(value_2);

% do something different ...
do_something();
% ... or simply sleep ...
pause(10);
% ... or simply do nothing ...

future.get();
future_2.get();
```

Waiting for channels to reach a certain value can be done as follows:

```matlab
// Wait without timeout (i.e. forever)
Channels.waitForValue(channel, 'world');

// Wait with timeout
Channels.waitForValueAsync(channel, 'world').get(java.lang.Long(10), java.util.concurrent.TimeUnit.SECONDS);
```

If you want to do stuff while waiting you can implement a busy loop like this:

```matlab
future = Channels.waitForValueAsync(channel, 'world');
while not(future.isDone())
    % do something
end
```


After you are done working with a channel close the channel via

```Matlab
channel.close();
```

# Examples
Examples can be found in the [examples](examples) folder within this repository.

# Feedback
We very much appreciate your feedback! Please drop an [issue](../../issues) for any bug or improvement you see for this library!


# ca_matlab - Development
This package is currently based on the [jcae](https://github.com/paulscherrerinstitute/jcae/) library developed at PSI. Basically it is a repackaging of the library together with its dependencies.

Building this package is currently only possible within PSI.

To build the package use:

```bash
./gradlew build
```
__Note__: As soon as Matlab is based on a Java 8 SDK the backing library will be switched from [jcae](https://github.com/paulscherrerinstitute/jcae) to [ca](https://github.com/channelaccess/ca), which is a more modern and a clean Java library for Channel Access.
