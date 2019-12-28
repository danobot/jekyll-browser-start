---
  title: "Home Automation: Priority Locks"
  categories: [home automation]
  tags: [lighting, home assistant, python, locks, software architecure, design]
---

As a home automation set up grows in size and complexity, there are certain issues that manifest themselves. The problem of lighting has been discussed on this blog in various places; not only because it serves as a great example but also because it is a surprisingly complex problem to solve from a software architecture and implementation point of view. Many of it's intricacies can be applied to other aspects of home automations beyond the scope of lighting.

<!--more-->

My [latest attempt]({% post_url 2018-12-16-file-observer %}) at solving it saw the use of [AppDaemon](http://appdaemon.readthedocs.io/en/latest/index.html) to implement virtual `MotionLight` devices as Python Objects. I highly recommend you read that article, particularly the numbered requirements I identified because those are critical for a lighting system to be stable, usable, reusable and independent.
