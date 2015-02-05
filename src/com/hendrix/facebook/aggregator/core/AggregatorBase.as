package com.hendrix.facebook.aggregator.core
{
  import flash.events.Event;
  import flash.utils.getQualifiedClassName;
  
  import com.hendrix.facebook.core.FqlCommand;
  import com.hendrix.facebook.aggregator.core.interfaces.IIdFeed;
  
  /**
   * a Base posts aggregator based on FQL Commands that implements <code>IIdFeed</code>, intended for extending.<br>
   * TODO: switch to event listener system
   * 
   * @author Tomer Shalev
   */
  public class AggregatorBase extends FqlCommand implements IIdFeed
  {
    public static var AGGREGATOR_UPDATE:        String        = "AGGREGATOR_UPDATE";
    
    public static var AGGREGATOR_PACKET_SIZE:   uint          = 25;
    
    protected var _id:                          String        = null;
    
    //protected var _posts:                       IdCollection  = null;
    protected var _posts:                       Vector.<Object>   = null;
    
    /**
     * Head.... page ..... 
     */
    protected var _currentPageHead:             uint          = 0;
    protected var _currentPageTail:             uint          = 0;
    
    protected var cb_onWallFeedUpdate:          Function      = null;
    
    /**
     * Facebook posts aggregator.
     * @param $pageId the Facebook page id to be aggregated
     * @param $access_token a valid facebook access token
     * @param $access_tokenExpiry token expiry date
     */
    public function AggregatorBase($access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      super($access_token, $access_tokenExpiry);
      
      _posts                = new Vector.<Object>();//new IdCollection("post_id");
    }
    
    /**
     *
     * @inheritDoc
     */
    public function resetPagingWindow($currentHeadIndex:uint = 0, $currentTailIndex:uint = 0):void
    {
      _currentPageHead = $currentHeadIndex;
      _currentPageTail = $currentTailIndex;
    }
    
    /**
     * get a feed 
     * @param $onWallFeedUpdate listener to be notified async if feed is not available
     * @return <code>null</code> if feed is not available, otherwise a vector of objects.
     */
    public function getFeed($onWallFeedUpdate:Function = null):void
    {
      if(_posts.length == 0) 
      {
        if($onWallFeedUpdate is Function)
          refreshFeed($onWallFeedUpdate);
      }
      else {
        if($onWallFeedUpdate is Function){
          $onWallFeedUpdate(_posts.slice(0));
        }
      }
    }
    
    /**
     * @inheritDoc
     */
    public function refreshFeed($onWallFeedUpdate:Function = null):Boolean
    {
      if(isBusy)
        return false;
      
      /**
       * if it is the first feed then grab items without filtering by time. otherwise, get the latest conditioning on time.
       */
      //_fql["query1"]                  = "SELECT created_time,message,post_id,likes,comment_info,attachment FROM stream WHERE source_id=" + _pageId + " LIMIT " + AGGREGATOR_PACKET_SIZE;        
      //_fql["comments"]                = "SELECT text,post_id,time,likes FROM comment WHERE post_id IN (SELECT post_id FROM #query1)";
      
      loadRequest(_fql, "refreshFeed", $onWallFeedUpdate);
      
      return (true);
    }
    
    /**
     * @inheritDoc
     */
    public function nextPageFeed($onWallFeedUpdate:Function = null):Boolean
    {     
      if(isBusy)
        return false;
      
      // check residual elements
      cb_onUpdate = $onWallFeedUpdate;
      if(_posts.length - (_currentPageTail) > 0) 
      {
        var availablePageSize:  uint  = Math.min(_posts.length - (_currentPageTail), AGGREGATOR_PACKET_SIZE);
        _currentPageHead              = _currentPageTail;
        _currentPageTail              = _currentPageHead + availablePageSize;
        notifyData(_currentPageHead, _currentPageTail);
        //trace(_currentPageHead);
        return true;
      }
      
      
      //_fql["query1"]                  = "SELECT created_time,message,post_id,likes,comment_info,attachment FROM stream WHERE source_id=" + _pageId + "and created_time<" + _posts.vec[_posts.count - 1].created_time + " ORDER BY created_time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;
      //_fql["comments"]                = "SELECT text,post_id,time,likes FROM comment WHERE post_id IN (SELECT post_id FROM #query1)";
      
      loadRequest(_fql, "nextPageFeed", $onWallFeedUpdate);
      
      return (true);
    }
    
    /**
     * @inheritDoc
     */
    public function prevPageFeed($onWallFeedUpdate:Function = null):Boolean
    {     
      if(isBusy)
        return false;
      
      cb_onUpdate = $onWallFeedUpdate;
      
      if(_currentPageHead > 0) {
        var availablePageSize:  uint    = Math.min(AGGREGATOR_PACKET_SIZE, _currentPageHead);
        _currentPageTail                = _currentPageHead;
        _currentPageHead                = _currentPageTail - availablePageSize;
        notifyData(_currentPageHead, _currentPageTail);
        return true;
      }
      
      
      /**
       * if it is the first feed then grab items without filtering by time. otherwise, get the latest conditioning on time.
       */
      //_fql["query1"]                  = "SELECT created_time,message,post_id,likes,comment_info,attachment FROM stream WHERE source_id=" + _pageId + "and created_time>" + _posts.vec[0].created_time + " ORDER BY created_time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;
      //_fql["comments"]                = "SELECT text,post_id,time,likes FROM comment WHERE post_id IN (SELECT post_id FROM #query1)";
      
      loadRequest(_fql, "prevPageFeed", $onWallFeedUpdate);
      
      return (true);
    }
    
    /**
     * @inheritDoc
     */
    public function disposeFeedData():void
    {
      if(_posts)
        _posts.length = 0;
      
      isBusy = false;
    }
    
    public function get id():             String  { return _id;   }
    public function set id(value:String): void    { _id = value;  }
    
    /**
     * @inheritDoc
     */
    override protected function onGraphRequestResponse(event:Event, $notifyListener:Boolean = true):void
    {
      try {
        var data: Object      = JSON.parse(event.target.data);
      }
      catch(err:Error)  {
        trace(err)
        onGraphRequestFailed(event);
        return;
      }
      
      // we asked for AGGREGATOR_PACKET_SIZE, feedsize <= AGGREGATOR_PACKET_SIZE will show the actual size we got.
      var feedSize:   uint;
      var requestId:  String  = event.target.id;
      trace("MrFacebookAggregator.onGraphRequestResponse(): requestId=" + requestId);
      
      // nextPageFeed, prevPageFeed are marginal cases where feed has ran out, and that's why we apply exterme _currentPageHead assaignments
      switch(requestId) {
        case "nextPageFeed":
          feedSize            = processFeed(data, "BOTTOM");
          _currentPageHead    = _posts.length - feedSize;
          _currentPageTail    = _posts.length;
          break;
        case "prevPageFeed":
          _currentPageHead    = 0;
          feedSize            = processFeed(data, "TOP");
          _currentPageTail    = _currentPageHead + feedSize;
          break;
        case "refreshFeed":
          _currentPageHead    = 0;
          disposeFeedData();
          feedSize            = processFeed(data, "TOP");
          _currentPageTail    = _currentPageHead + feedSize;
          break;
        case "fqltest":
          break;
        default:
          throw new Error("MrPageAggregator.onGraphRequestResponse(...): No processing behaviour was found for request id: " + requestId + " !!!");
          return;
      }
      
      _ul.removeEventListener( Event.COMPLETE, onGraphRequestResponse);
      
      notifyData(_currentPageHead, _currentPageTail);
    }
    
    /**
     * process the feed, arrange data etc.. 
     * @param $feed the unprocessed data
     * @param $position <code>BOTTOM</code> or <code>TOP</code> indicating insertion at the <i>top</i> or <i>bottom</i> of <code>this._posts</code>
     * @return the number of items got in feed 
     */
    public function processFeed($feed:Object, $position:String = "BOTTOM"):uint
    {
      var posts:          Array   = $feed.data[0].fql_result_set as Array;
      var posts_comments: Array   = $feed.data[1].fql_result_set as Array;
      var post:           Object  = null;
      var ix:             int;
      
      if(posts.length == 0)
        return 0;
      
      switch($position)
      {
        case "TOP":
        {
          for(ix = posts.length - 1; ix >= 0; ix--) {
            // add comments vector to posts
            posts[ix].comments    = new Vector.<Object>;
            _posts.push(posts[ix], 0);
          }
          break;
        }
        case "BOTTOM":
        {
          for(ix = 0; ix < posts.length; ix++)  {
            // add comments vector to posts
            posts[ix].comments    = new Vector.<Object>;
            _posts.push(posts[ix]);
          }
          break;
        }
        default:
        {
          throw new Error("invalid argument position: should be BOTTOM or TOP");
          break;
        }
      }
      
      /*
      // add comments
      for(ix = 0; ix < posts_comments.length; ix++) {
      post                      = _posts.getById(posts_comments[ix].post_id);
      post.comments.push(posts_comments[ix]);
      }
      */
      return posts.length;
    }
    
    public function get feedSize():uint
    {
      return _posts.length;
    }
    
    public function stopFeed():void
    {
      stopRequest();
    }
    
    /**
     * notify a Vector of data to the listener. 
     * @param $startIndex the first index
     * @param $endIndex the las index
     */
    private function notifyData($startIndex:uint = 0, $endIndex:uint = uint.MAX_VALUE):void
    {
      trace($startIndex+"x"+$endIndex);
      if($endIndex == uint.MAX_VALUE) {
        $endIndex = _posts.length;
      }
      
      //dispatchEventWith(AGGREGATOR_UPDATE, false, _posts.vec.slice($startIndex, $endIndex));
      
      notifyListener(_posts.slice($startIndex, $endIndex));
      
      isBusy = false;
    }
    
    
    /**
     * 
     * GRAPH REQUEST RAW EXAMPLES.
     * 
     */
    /*  Graph requestd examples
    /*
    // regular batch
    var a1:Object = new Object();
    a1["method"] = "GET";
    a1["relative_url"] = "260689792175_10200366545152298?fields=comments,likes,id";
    
    var a2:Object = new Object();
    a2["method"] = "GET";
    a2["relative_url"] = _facebookId + "/feed";
    
    var arr:Array = [a1, a2];
    
    var bundle:Object = new Object();
    bundle.batch = arr;
    bundle.requestid = 'myPostsUpdate';
    
    
    GVutils.goViral.facebookGraphRequest("", GVHttpMethod.POST, bundle, null);
    */
    
    //regular graph path call
    // params:Object = new Object();
    //params.requestid = "pageFeed";
    //GVutils.goViral.facebookGraphRequest(_facebookId + "/feed", GVHttpMethod.GET, params, null);
    
    // fql
    /*
    //{
    //"query1":"SELECT message,post_id,likes,comment_info,attachment FROM stream WHERE source_id=260689792175",
    //"comments":"SELECT text,post_id,time,likes FROM comment WHERE post_id IN (SELECT post_id FROM #query1)",
    //
    //}
    
    _fql["query1"] = "SELECT created_time,message,post_id,likes,comment_info,attachment FROM stream WHERE source_id=260689792175 LIMIT 25";
    _fql["comments"] = "SELECT text,post_id,time,likes FROM comment WHERE post_id IN (SELECT post_id FROM #query1)";
    
    _params.q = _fql;
    _params.requestid = "refreshFeed";
    GVutils.goViral.facebookGraphRequest("fql", GVHttpMethod.GET, _params, null);
    
    */
  }
}