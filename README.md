Influence
=========
Influence is an open-source project to visualize campaign contributions and explore the impact of money on democracy. There are many web applications dealing with government transparency, but we felt they made a common mistake: because there is so much transparency data, these sites felt compelled to show it all. We wanted to show a smaller set of data that has been visualized in a compelling way, allowing people to more easily draw their own conclusions without injecting any partisan bias.

Our Team
--------
Influence was created at [Hack Reactor](http://www.hackreactor.com) by:
* [Gregory Hilkert](https://github.com/EpiphanyMachine)
* [Cyd La Luz](https://github.com/quetzaluz)
* [Jake McGuire](https://github.com/eastbayjake)
* [Ricky Sidhu](https://github.com/riksidhu)
* [Josh Sprague](https://github.com/joshsprague)

You can learn more about the team [here](http://www.tildenapp.com/#/about). (We're all for hire!)

Using the App
=============
Influence became the deployed web app [Tilden](http://www.tildenapp.com). Here's a quick walkthrough of functionality:

District Map
------------
Search for your legislator by clicking your state/district, enter your zip code or city, or geolocate using your computer's current location.

![alt-text](https://raw.github.com/IdeaHaven/influence/master/screenshots/districtmap1.png "District Map: Detail View")

![alt-text](https://raw.github.com/IdeaHaven/influence/master/screenshots/districtmap2.png "District Map: Search the US")

Individual View
---------------
See campaign donations, top contributors, and personal information about members of Congress.

Compare Reps
------------
Compare legislators' contributors and donation amounts in a head-to-head matchup. This view will show any contributors that the two legislators have in common. The D3 circle graphs show the relative sizes of top donors to each representative.

Word Explorer
-------------
Search for the top words used by an individual legislator, or see how often a word or phrase has been used in Congress since 1996.

![alt-text](https://raw.github.com/IdeaHaven/influence/master/screenshots/words1.png "Word Explorer: See Speech Trends")

Bill Search
-----------
View the full text of bills in Congress. Search for bills by issue/word or select from a list of the most recent bills. Comment on your findings in the Disqus comments below each bill.

![alt-text](https://raw.github.com/IdeaHaven/influence/master/screenshots/bills1.png "Bill Search: Find by issue")


About the Stack
===============
Influence is an AngularJS app written in CoffeeScript. It uses a Node.js API server with ActionHero.js and a PostgreSQL database. Test coverage is provided by Travis-CI.

Seed Generator
--------------
This was created using the [Yeoman Angular Generator](https://github.com/yeoman/generator-angular).  The bootstrap files were replaced with [bootstrap-stylus](https://github.com/Acquisio/bootstrap-stylus) and [Angular UI Bootstrap Directives](http://angular-ui.github.io/bootstrap/)

Quick Start
-----------
    `npm install -g bower grunt-cli` unless you have them already
    `npm install`
    `bower install`
    `grunt dev`
    `http://localhost:8080`

How to add new angular modules using yeoman
-------------------------------------------
Have [Yeoman](http://yeoman.io/) installed globally
Have [Yeoman Angular Generator](https://github.com/yeoman/generator-angular) installed
Follow the directions [here](https://github.com/yeoman/generator-angular) *USING* flags: `--coffee --minsafe`

Global Package Requirements
---------------------------
* [Node](http://nodejs.org/)
* after node is installed run: `npm install -g bower grunt-cli yo generator-angular`
 * [Bower](http://bower.io/)
 * [Grunt-CLI](http://gruntjs.com/)
 * yo and angular-generator info the Yeoman Section above

License
=========
Influence is licensed under the [Affero General Public License](LICENSE), which is like the GPL but *requires* you provide access to the source code for any modified versions that are running publicly (among other things). The [intent](http://www.gnu.org/licenses/why-affero-gpl.html) is to make sure that anyone improving the software makes those improvements available to others, as we have to them.
