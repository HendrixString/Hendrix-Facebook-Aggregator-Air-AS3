package com.hendrix.facebook.core
{
  import com.hendrix.facebook.aggregator.core.types.IdUrlLoader;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLVariables;
  import flash.utils.ByteArray;
  
  /**
   * a small class to implement Facebook graph request, intended for both inheritance/extension or encapsulation.
   * <li><code>this.dataLatest</code> will have the result of the query, it is optional to use it. you can override <code>onGraphRequestResponse</code> method.
   * <li><code>this.params</code> can store the params command object.
   * @author Tomer Shalev
   */
  public class GraphRequest
  {
    protected var cb_onUpdate:            Function      = null;
    
    protected var _access_token:          String        = null;
    protected var _access_tokenExpiry:    Number        = -1;
    
    private var _params:                  Object        = null;
    protected var _paramsAux:             Object        = null;
    
    protected var _ul:                    IdUrlLoader   = null;
    protected var _ur:                    URLRequest    = null;
    protected var _urlVariables:          URLVariables  = null;
    
    protected var _method:                String        = null;
    
    protected var _path:                  String        = null;
    
    protected var _dataLatest:            Object        = null;
    
    private var _isBusy:                  Boolean       = false;
    
    /**
     * a small class to implement Facebook graph request, intended for both inheritance/extension or encapsulation.
     * <li><code>this.dataLatest</code> will have the result of the query, it is optional to use it. you can override <code>onGraphRequestResponse</code> method.
     * <li><code>this.params</code> can store the params command object.
     * @param $path a valid facebook relative path, like "/me"
     * @param $method <code>URLRequestMethod.GET</code> or <code>URLRequestMethod.POST</code>
     * @param $access_token a valid facebook access token
     * @param $access_tokenExpiry token expiry date
     */
    public function GraphRequest($path:String = "/me", $method:String = URLRequestMethod.GET, $access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      _access_token                 = $access_token;
      _access_tokenExpiry           = $access_tokenExpiry;
      _method                       = $method;
      
      _path                         = $path;
      
      _params                       = new Object();
      
      _ul                           = new IdUrlLoader();
      
      _urlVariables                 = new URLVariables();
      _urlVariables['access_token'] = _access_token;
      
      _ur                           = new URLRequest("https://graph.facebook.com" + _path);
      _ur.method                    = _method;
      
      _ul.addEventListener(IOErrorEvent.IO_ERROR, onGraphRequestFailed);
      _ul.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
    }
    
    /**
     * load the graph request 
     * @param $params if null then it will use <code>this.params</code> (making this class appropriate for both extending and encapsulation)
     * @param $commandId the id of the urlloader (optional)
     * @param $onUpdate a listener callback (optional)
     * @param $resetUrlVars url variables are generally in place, but can be reset with this option
     * @param $resetParamsAfterRequest params reset if you do not wish in place usage
     */
    public function loadRequest($params:Object = null, $commandId:String = null, $onUpdate:Function = null, $resetUrlVars:Boolean = false, $resetParamsAfterRequest:Boolean = false):void
    {
      if(!isAccessTokenAvailable())
        throw new Error("No access token, or access token has expired");
      
      if($resetUrlVars)
        resetUrlVariables();
      
      cb_onUpdate                     = $onUpdate;
      
      _paramsAux                      = $params ? $params : _params;
      
      /**
       * if it's a key/value pair object than make it a JSON, this the common way in facebook to pass
       * complex values of url variables, for example fql query that it's value is a compund object. if it is a bytearray or string then don't.
       */
      for (var k:String in _paramsAux) {
        if(!(_paramsAux[k] is ByteArray) && !(_paramsAux[k] is String))
          _paramsAux[k]               = JSON.stringify(_paramsAux[k]);
        _urlVariables[k]              = _paramsAux[k];
      }
      
      _ur.data                        = _urlVariables;
      
      if($resetParamsAfterRequest) {
        for (var p:String in _params) {
          delete _params[k];
        }
      }
      
      _ul.id                          = $commandId;
      _ul.addEventListener( Event.COMPLETE, onGraphRequestResponse);
      _ul.load(_ur);
    }
    
    /**
     * override this for a more custom behaviour
     * @param event
     * @param $notifyListener set this false if you dont want to notify a listener
     */
    protected function onGraphRequestResponse(event:Event, $notifyListener:Boolean = true):void
    {
      try{
        _dataLatest           = JSON.parse(event.target.data);
      }
      catch(err:Error) {
        trace(err)
        onGraphRequestFailed();
        return;
      }
      
      _ul.removeEventListener( Event.COMPLETE, onGraphRequestResponse);
      
      if($notifyListener)
        notifyListener(this);
    }
    
    /**
     * notify null 
     */
    protected function onGraphRequestFailed(event:Object = null):void
    {
      if(event)
        trace(event.currentTarget.data)
      _isBusy = false;
      stopRequest();
      notifyListener(null);
    }
    
    /**
     * gives better introspection of http request
     */
    private function httpStatusHandler(event:HTTPStatusEvent):void
    {
      trace("GraphRequest.httpStatusHandler(), status code : "  + event.status);
      //trace("GraphRequest.httpStatusHandler(), response : "     + event.currentTarget.data);
      if(uint(event.status) >= 400) {
        //onGraphRequestFailed();
      }
    }
    
    /**
     * notify listener 
     * @param $obj the Object to return to the listerner
     */
    protected function notifyListener($obj:*):void
    {
      if(cb_onUpdate is Function)
        cb_onUpdate($obj);
    }
    
    public function removeListeners():void
    {
      cb_onUpdate = null;
    }
    
    public function stopRequest():void
    {
      _ul.removeEventListener( Event.COMPLETE, onGraphRequestResponse);
      
      try{
        _ul.close();
      }
      catch(err:Error) {
        
      }
      
      _isBusy = false;
    }
    
    /**
     * check if access token is available and has not expired
     */
    public function isAccessTokenAvailable():Boolean
    {
      //return ((_access_token) && (_access_tokenExpiry > (new Date()).time));
      return _access_token;
    }
    
    /**
     * a good practice is to check if a feed request is already waiting for response
     */
    public function get isBusy():Boolean
    {
      _isBusy = _isBusy || _ul.hasEventListener(Event.COMPLETE);
      return (_isBusy);
    }
    public function set isBusy(value:Boolean):void
    {
      _isBusy = value;
    }
    
    /**
     * dispose this object
     */
    public function dispose():void
    {
      removeListeners();
      
      _access_token       = null;
      _access_tokenExpiry = -1;
      
      reset();
      
      if(_ul) {
        try {
          _ul.close();
        }
        catch(err:Error) {}
        
        _ul.removeEventListener(IOErrorEvent.IO_ERROR, onGraphRequestFailed);
        _ul.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        _ul.removeEventListener( Event.COMPLETE, onGraphRequestResponse);
        _ul.data          = null;
        _ul               = null;
      }
      
      _ur                 = null
    }
    
    /**
     * reset the object. it will not reset access token, path and callback, only the url variables since it is inplace.
     */
    public function reset():void
    {
      _params                       = null;
      _paramsAux                    = null;
      
      if(_ul)
        _ul.id                      = null;
      
      resetUrlVariables();
      
      _dataLatest                   = null;
    }
    
    /**
     *  reset only the urlVariables since they are in place 
     */
    public function resetUrlVariables():void
    {
      _urlVariables                 = null;
      _urlVariables                 = new URLVariables();
      _urlVariables['access_token'] = _access_token;
    }
    
    public function get access_token():                   String  { return _access_token;         }
    public function set access_token(value:String):       void    
    { 
      _access_token                   = value;
      _urlVariables['access_token']   = _access_token;
    }
    
    public function get access_tokenExpiry():             Number  { return _access_tokenExpiry;   }
    public function set access_tokenExpiry(value:Number): void    { _access_tokenExpiry = value;  }
    
    /**
     * latest data packet that has returned 
     */
    public function get dataLatest():                     Object  { return _dataLatest;           }
    
    /**
     * use <code>this.params</code> to inject <i>key / values</i> pairs for the request 
     */
    public function get params():                         Object  { return _params; }
    public function set params(value:Object):             void    { _params = value;  }
    
    /**
     * Http method: <code>URLRequestMethod.GET</code> or <code>URLRequestMethod.POST</code>
     */
    public function get method():                         String  { return _method; }
    public function set method(value:String):             void
    {
      _method     = value;
      _ur.method  = _method;
    }
    
    public function get path():                           String  { return _path; }
    public function set path(value:String):               void
    {
      _path = value;
      _ur.url = "https://graph.facebook.com" + _path;
    }
    
    
  }
}