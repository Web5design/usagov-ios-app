USA.gov for iOS mobile application
=============

The USA.gov iOS mobile application allows you to:

* Search tens of millions of web pages from federal, state, local, territorial, and tribal governments and to contact your government by phone or email.
* Find quality images from U.S. government web sites
* Search product recalls across several government agencies
* Visit the USA.gov blog
* Contact USA.gov

By releasing the source code for this app we hope to empower other governments and organizations to build and release mobile apps to engage the general public and their own specific constituencies. In addition, public review and contribution to the application's code base will help strengthen and improve the app.

Requirements to run the iOS mobile application
----------------------------------------------

1. iPhone, iPad, iPod Touch iOS version 4.3 or later
2. JSON feeds for content to be aggregated and displayed by the app

Working with the Source Code
----------------------------

Mobile developers will be able to configure the application to retrieve and display content from arbitrary USA Search and Recalls JSON feeds. Assets may be replaced to customize the app's look and feel.

Building the app requires the iOS 4.3 SDK or higher.

This app makes use of several libraries in source, binary, and submodule form.

The following sections describe all of the libraries and any steps necessary to initialize them.

### Included Libraries

The following libraries are directly included as source code:

1. YAJL
2. JSON

### Search Functionality
Search functionality relies on USASearch, a hosted search service provided by the U.S. General Services Administration (GSA). Federal, state, local, tribal, or territorial government websites may use this service at no cost. For details on incorporating USASearch into .Gov sites, or for examples of the API and how it functions, see the [USASearch website](http://usasearch.howto.gov/) and the [USASearch API documentation](http://usasearch.howto.gov/manual/api.html), respectively.

NOTE: Setting up the application and configuring it for use in your organization's context requires iOS development experience. The application ships with a similar design to what is used in the USA.gov for iOS mobile application. 

Roadmap
-------

Have an idea or question about future features for USA.gov for iOS? Let us know by opening a ticket on GitHub, tweeting [@USAGOV](https://twitter.com/USAgov), or via our [feedback form](http://answers.usa.gov/system/selfservice.controller?CONFIGURATION=1000&PARTITION_ID=1&CMD=STARTPAGE&SUBCMD=EMAIL&USERTYPE=1&LANGUAGE=en&COUNTRY=us)

Contributing
------------

Anyone is encouraged to contribute to the project by forking and submitting a pull request. (If you are new to GitHub, you might start with a basic tutorial.)

By contributing to this project, you grant a world-wide, royalty-free, perpetual, irrevocable, non-exclusive, transferable license, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the conditions that any appropriate copyright notices and this permission notice are included in all copies or substantial portions of the Software.

License
-------
This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.

However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License. http://opensource.org/licenses/mit-license.php. 
Under that license, permission is granted free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the conditions that any appropriate copyright notices and this permission notice are included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
