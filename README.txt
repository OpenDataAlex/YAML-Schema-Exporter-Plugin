SQL Power Architect YAML Schema Template Plugin
http://github.com/dbaAlex/YAML-Schema-Exporter-Plugin
-------------------------------------------------

Introduction
------------

This is an XLST template for use with SQL Power Architect
(http://www.sqlpower.ca/page/architect), an Open Source data modeling and
profiling tool.  This set of templates will export a database model into
a yaml schema file.  Current focus is on the Doctrine ORM framework, with
plans for a Propel ORM framework template.  If there are any other frameworks
that use a YAML schema file and you wish to either suggest or help create the
template, please post on GitHub.

Installation
------------

To install any or all of the templates and make them available to SQL Power Architect,
take the templates folder and copy it to a safe location on your pc.  Open up
Power Architect and select a project that you wish to try the YAML templates on.
Once the project is open, select File > Export to HTML.  A pop-up will open asking
what template you wish to use.  Select the second option "Use custom template (XSLT or Velocity)"
and find the template that you wish to use.  You can optionally set the Output File.

Clicking on the Start button will begin the transformation.  Upon completion, the
schema should open in your browser.  Congratulations, you now have a freshly minted
YAML Schema file!


Troubleshooting
--------------
If the schema file did not export properly, or failed to export at all, please
add a ticket over on GitHub.  We can't improve the project unless we receive
feedback.