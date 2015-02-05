package com.hendrix.facebook.aggregator.core.types
{
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  
  import com.hendrix.facebook.aggregator.core.interfaces.IId;
  
  /**
   * a <code>URLLoader</code> with <code>id</code>
   * @author Tomer Shalev
   */
  public class IdUrlLoader extends URLLoader implements IId
  {
    private var _id:  String;
    
    /**
     * a <code>URLLoader</code> with <code>id</code>
     */
    public function IdUrlLoader(request:URLRequest=null)
    {
      super(request);
    }
    
    public function get id():             String  { return _id;   }
    public function set id(value:String): void    { _id = value;  }
  }
}