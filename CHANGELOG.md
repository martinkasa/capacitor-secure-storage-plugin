## v0.5.0

- added keys() method - warning: returns just keys saved from this version up
- iOS: instead on standard keychain, wrapper service is used
- migration is not needed, plugin saves new values to wrapped keychain and get method uses standard keychain as a fallback

## v0.4.0

- rebased on Capacitor v2 plugin template
- added getPlatform() method

## v0.3.2

- update Capacitor dependencies

## v0.3.1

- fix long string handling
