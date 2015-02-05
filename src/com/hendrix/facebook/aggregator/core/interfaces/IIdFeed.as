package com.hendrix.facebook.aggregator.core.interfaces
{
  public interface IIdFeed extends IId
  {
    /**
     * get the most recent page of posts (25 by default).
     * returns false if feed is busy, true if your request made it busy.
     * intended mostly for internal usage, but can be used for forcing a fresh feed acquisition.
     */
    function refreshFeed($onWallFeedUpdate:Function = null):  Boolean;
    
    /**
     * get next page of posts (default is 25) or a fresh feed depending on if posts are abscent.
     * if aggregator is busy but there is some cached data, then it will return it.
     * @param $onWallFeedUpdate listener to be notified async
     * @return <code>False</code> if aggregator is busy or error, <code>True</code> otherwise.
     */
    function nextPageFeed($onWallFeedUpdate:Function = null): Boolean;
    
    /**
     * get previous page of posts (default is 25) or a fresh feed depending on if posts are abscent.
     * if aggregator is busy but there is some cached data, then it will return it.
     * @param $onWallFeedUpdate listener to be notified async
     * @return <code>False</code> if aggregator is busy or error, <code>True</code> otherwise.
     */
    function prevPageFeed($onWallFeedUpdate:Function = null): Boolean;
    
    /**
     * gets all of the feed, returns null if feed is empty and returns a refreshFeed if so aSync.
     * @param $onWallFeedUpdate a listener callback
     * @return  all of the feed as a <code>Vector</code> 
     */
    function getFeed($onWallFeedUpdate:Function = null):      void;
    
    /**
     * resets paging window indicator, this is a good practice when starting reading from any feed, since it might be used by
     * sometime at the past and it's windowing/paging is not at the begining.
     */
    function resetPagingWindow($currentHeadIndex:uint = 0, $currentTailIndex:uint = 0):                             void;
    
    /**
     * dispose all the posts. if you call <code>getFeed(...)</code> after, then you will get fresh feed. 
     */
    function disposeFeedData():                               void;
    
    /**
     * process the feed, arrange data etc.. 
     * @param $feed the unprocessed data
     * @param $position <code>BOTTOM</code> or <code>TOP</code> indicating insertion at the <i>top</i> or <i>bottom</i> of <code>this._posts</code>
     * @return the number of items got in feed 
     */
    function processFeed($feed:Object, $position:String = "BOTTOM"):uint;
    
    function stopFeed():void;
    
    function get feedSize():uint;
    
    //function addEventListener(type:String, listener:Function):void;
  }
}