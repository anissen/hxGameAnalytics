class Test {
    static function main() {
        var analytics = new Analytics('5c6bcb5402204249437fb5a7a80a4959', '16813a12f718bc5c620f56944e1abc3ea13ccbac');
        trace('analytics.init');
        analytics.init();
        trace('-----------------------------------------');
        trace('events');
        analytics.event({ event_id: "player:death:shotgun", build: 'alpha 0.0.1' });
        trace('done');
    }
}
