package localServer 
{
	/**
	 * ...
	 * @author jerry.d
	 */
	public class ServerCard 
	{
		public var value:int;
		public var realValue:int;
		public var type:int;
		public function ServerCard(value:int) 
		{
			this.value = value;
			this.realValue = (card - 1)%13 + 1;
			this.type = Math.floor(value/13);//1 2 3 4
		}
		
	}

}