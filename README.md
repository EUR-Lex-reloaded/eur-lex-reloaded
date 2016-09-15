# eur-lex-reloaded

## The purpose

... of this project is to improve the accessability of the documents of European legislation as made available on http://eur-lex.europa.eu.

Especially missing was the availablity of a fully linked Table of Content to have fast access to certain articles or annexes. Furthermore I wanted to be able to link to these points within these lengthy documents from other (own) documents, e.g. referencing for research purposes. Therefore the enhancement with "speaking" anchors was a main goal.

## This solution

... is server-oriented. You need a web server, where you can run Ruby as CGI. You access your EUR-Lex documents through your webserver, that does the magic of augmenting the pages with these new accessibility features.

To facilitate usage, the main page provides a *bookmarklet*  that you can drag into your browser and use directly to redirect and transform a document as you browse on http://eur-lex.europa.eu.

## Getting started

The whole project is implemented in RUBY and contained in [./toccata.rb]().

## Installation Guide

1. Move the [./toccata.rb]() file to the `cgi-bin` folder of your webspace.
2. Enhance the `.htaccess` file of the `DOCUMENT ROOT` of your webspace (e.g. `.../htdocs`) with the following line:
    ```
    DirectoryIndex /cgi-bin/toccata.rb
    ```
3. Browse to your webspace.

If you want to automize the deployment you can adapt the [./deploy.sh]() to your own webserver environment, copy it to `bin/` in your home directory and install it as `post-update` hook (or `post-receive`, if your prefer) in your bare git repository clone on your production machine. To do this your file <repostitory-name>/hooks/post-update contains the following:
```
#!/bin/sh

${HOME}/bin/deploy.sh
```
Then with every `git push' , your system gets updated.

## License
You can use this code under the [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

The use of the EUR-Lex documents for these purposes to me seems covered by the Open Access Policy and licensing terms I found on their website: http://eur-lex.europa.eu/content/legal-notice/legal-notice.html#droits

Disclaimer: I am not a lawyer, therefore I might be wrong on this. I will not take any responsibility or liability related to the usage of the code of this project.
