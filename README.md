# hxGameAnalytics

Cross platform GameAnalytics integration library.

Notice: _This is a work in progress and not ready for production_. Feel free to create issues or pull requests though.

### Example usage

```haxe
var analytics = new Analytics('5c6bcb5402204249437fb5a7a80a4959', '16813a12f718bc5c620f56944e1abc3ea13ccbac');
analytics.init();
analytics.event({ event_id: "player:death:shotgun", build: 'alpha 0.0.1' });
```
