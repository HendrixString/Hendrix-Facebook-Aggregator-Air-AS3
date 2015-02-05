package com.hendrix.facebook.core
{
  import flash.net.URLRequestMethod;
  
  
  /**
   * a small class to implement FQL commands to facebook, intended for both inheritance/extension or encapsulation.
   * <li><code>this.dataLatest</code> will have the result of the query, it is optional to use it. you can override <code>onGraphRequestResponse</code> method.
   * <li><code>this.fql</code> can store the FQL command object.
   * @author Tomer Shalev
   */
  public class FqlCommand extends GraphRequest
  {
    protected var _fql: Object  = null;
    /**
     * a small class to implement fql commands to facebook, intended for both inheritance/extension or encapsulation.
     * <li><code>this.dataLatest</code> will have the result of the query, it is optional to use it. you can override <code>onGraphRequestResponse</code> method.
     * @param $access_token a valid facebook access token
     * @param $access_tokenExpiry token expiry date
     */
    public function FqlCommand($access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      _fql  = new Object();
      
      super("/fql", URLRequestMethod.GET, $access_token, $access_tokenExpiry);
    }
    
    /**
     * load the fql command from an object 
     * @param $params if null then it will use <code>this.fql</code>
     * @param $commandId the id of the urlloader
     * @param $onUpdate a listener callback
     */
    override public function loadRequest($params:Object=null, $commandId:String=null, $onUpdate:Function=null, $resetUrlVars:Boolean = false, $resetParamsAfterRequest:Boolean = false):void
    {
      if($params == null)
        $params         = fql;
      
      super.params["q"] = $params; 
      
      super.loadRequest(params, $commandId, $onUpdate, $resetUrlVars, $resetParamsAfterRequest);
    }
    
    public function get fql():              Object  { return _fql;  }
    public function set fql(value:Object):  void    { _fql = value; }
    
    override public function set params(value:Object):void
    {
      throw new Error("use this.fql instead");
    }
  }
}