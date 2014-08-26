WikiFutzer
==========

Written for the Las Vegas iOS Developers Meetup group in August 2014.


An iOS GCD/Table demo that uses Wikipedia for a source of data.  Entering an article will list that article and every article linked from the original, along with a thumbnail of a random image from each page.

It uses synchronous web requests for the sole purpose of demonstrating the effect of blocking the main thread and how GCD can be used to solve that issue.
