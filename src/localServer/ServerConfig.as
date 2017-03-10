package localServer 
{
	/**
	 * ...
	 * @author jerry.d
	 */
	public class ServerConfig 
	{
		public static var Games:Object = {};
		/** PROTOCOLS **/
		public static const S_R_LOGIN:int = 0;//login back
		public static const S_B_HEARTBEAT:int = 1;//broadcast heartbeat
		public static const S_B_DISPENSE:int = 2;//dispense or hit
		public static const S_B_TURN:int = 3;//broadcast trun
		public static const S_R_BET:int = 4;//return add bet
		public static const S_R_STAND:int = 5;//stand
		public static const S_R_SPLIT:int = 6;//split
		public static const S_R_SURRENDER:int = 7;//surrender
		public static const S_B_END:int = 8;//end
		public static const S_R_START:int = 9;//return start
		public static const S_R_DOUBLE:int = 10;//return double
		public static const S_R_HIT:int = 11;//return hit
		public static const S_B_ROUND_END:int = 12;// round end clean table
		public static const S_R_INSURE:int = 13;// return insurrance result
		public static const S_B_FAKE_CARD:int = 14;// return insurrance result
		public static const S_B_PAIR_RESULT:int = 15;// return insurrance result

		/** request from client **/
		public static const C_LOGIN :int = 0;//login success
		public static const C_START:int = 1;// start and dispense, if has bet
		public static const C_SPLIT :int = 2;//split 
		public static const C_HIT :int = 3;// hit
		public static const C_STAND :int = 4;//stand
		public static const C_DOUBLE :int = 5;//double
		public static const C_INSURRANCE :int = 6;
		public static const C_SKIP_INSURRANCE :int = 7;
		public static const C_ADD_BET :int = 8;

		public static const RESULT_LOSE:int =-1;
		public static const RESULT_DRAW:int = 0 ;
		public static const RESULT_WIN:int = 1;

		//赔率
		public static const BLACKJACK:int = 1.5;
		public static const DRAGON:int = 2;
		public static const PAIR:int = 11;
	}

}