0.5.3
------
#### Enhancements
* Update to make with Elixir 1.4.0 (#35).

0.5.2
------
#### Changes
* Fix umbrella test count (#34).

0.5.1
------
#### Enhancements
* Add ex_doc for documentation (#32).

0.5.0
------
#### Changes
* Updated triq dependency to point to more actively updated fork (#31).
* Fix for running test errors on erlang 19.

0.4.1
------
#### Changes
* Update formatter to handle older Elixir versions (#27).

0.4.0
------
#### Changes
* Update dependencies.
* Fix formatter crash in elixir 1.3.0 (#25).

0.3.3
------
#### Changes
* Resolve config at runtime rather than compile time (#22).

0.3.2
------
#### Enhancements
* Allow ExUnit tags to set iterations per test (#16).
   - Add ExCheck.check/2.

0.3.1
------
#### Changes
* Update dependencies.

0.3.0
------
#### Enhancements
* Add possibility to specify amount of tests in config (#13).
* Provide formatted output + better error loggings from property tests (#12).
   - Number of tests displayed in `mix test` result is now counts the number of generated tests.
