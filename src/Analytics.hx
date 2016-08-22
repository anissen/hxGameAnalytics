import haxe.crypto.Base64;
import haxe.crypto.Hmac;
import haxe.io.Bytes;
import haxe.Timer;

#if haxe3_3
@:structInit
#end
typedef EventData = {
    // required:
    ?device :String,         // e.g. 'iPhone6.1'
    ?v :Int,                 // e.g. 2
    ?user_id :String,        // e.g. 'AEBE52E7-03EE-455A-B3C4-E57283966239' /* unique user id */
    ?client_ts :Int,         // e.g. 1459945227 /* server ts + diff */
    ?os_version :String,     // e.g. 'ios 8.2'
    ?manufacturer :String,   // e.g. 'apple'
    ?platform :String,       // e.g. 'ios'
    ?session_id :String,     // e.g. 'f235e4d1-fbf1-11e5-b05d-34363bcb81c0' /* randomly generated per session */
    ?session_num :Int,       // e.g. 1 /* incremented by each session */
    ?sdk_version :String,    // e.g. "rest api v2"
    ?category :String,       // e.g. "design"

    // optional:
    event_id : String,      // e.g. "player:death:shotgun"
    build :String           // e.g. 'alpha 0.0.1'
}

class Analytics {
    var game_key :String;
    var secret_key :String;
    var server_ts :Int;
    var enabled :Bool;

    var events :Array<EventData>;
    var processing_timer :Timer;
    var process_interval :Int = 15; // seconds between processing events
    
    public function new(game_key :String, secret_key :String) {
        this.game_key = game_key;
        this.secret_key = secret_key;
        events = [];
        enabled = false;
    }
    
    public function init() {
        if (enabled) throw 'Already initialized!';

        var body = '{"platform": "ios", "sdk_version": "rest api v2", "os_version": "ios 8.2"}';
        var url = get_url('init');
        function onData(json :Dynamic) {
            enabled = json.enabled;
            server_ts = json.server_ts;
            #if haxe3_3
            if (json.enabled) {
                processing_timer = new Timer(process_interval * 1000);
                processing_timer.run = process_event_queue;
            }
            #end
        }
        request(url, body, onData);
    }
    
    public function event(data :EventData) {
        data.device      = (data.device       != null ? data.device : 'iPhone6.1');
        data.v           = (data.v            != null ? data.v : 2);
        data.user_id     = (data.user_id      != null ? data.user_id : 'AEBE52E7-03EE-455A-B3C4-E57283966239');
        data.client_ts   = (data.client_ts    != null ? data.client_ts : 1459945227);
        data.os_version  = (data.os_version   != null ? data.os_version : 'ios 8.2');
        data.manufacturer= (data.manufacturer != null ? data.manufacturer : 'apple');
        data.platform    = (data.platform     != null ? data.platform : 'ios');
        data.session_id  = (data.session_id   != null ? data.session_id : 'f235e4d1-fbf1-11e5-b05d-34363bcb81c0');
        data.session_num = (data.session_num  != null ? data.session_num : 1);
        data.sdk_version = (data.sdk_version  != null ? data.sdk_version : "rest api v2");
        data.category    = (data.category     != null ? data.category : "design");
        
        events.push(data);

        #if !haxe3_3
        process_event_queue();
        #end
    }

    public function process_event_queue() {
        trace('process_event_queue');
        var all_events = [ for (event in events) event ];
        var body = haxe.Json.stringify(all_events);
        function onData(json :Dynamic) {
            trace('process_event_queue reply: $json');
        }
        request(get_url('events'), body, onData);
    }
    
    function get_url(endpoint :String) {
        return 'http://sandbox-api.gameanalytics.com/v2/$game_key/$endpoint';
    }
    
    function request(url :String, body :String, ?onData :Dynamic->Void) {
        trace(url);
        trace(body);
        var http = new haxe.Http(url);
        http.onData = function(data :String) {
            trace('onData: $data');
            if (onData == null) return;
            var json = haxe.Json.parse(data);
            onData(json);
        };
        http.onStatus = function (status :Int) { trace('Status: $status'); };
        http.onError = function (msg :String) { trace('Error: $msg'); };
        http.addHeader('Content-Type', 'application/json');
        http.addHeader('Authorization', secret_hash(body));
        http.setPostData(body);
        #if js http.async = false; #end
        http.request(true);
    }
    
    function secret_hash(body :String) :String {
        return Base64.encode(new Hmac(SHA256).make(Bytes.ofString(secret_key), Bytes.ofString(body)));
    }
}
