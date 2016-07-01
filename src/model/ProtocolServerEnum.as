package model 
{
	/**
	 * ...
	 * 服务端推送以及返回结果
	 * @author jerry.d
	 */
	public class ProtocolServerEnum 
	{
		//S(SERVER)_(R:RETURN|B:BROADCAST)_XXX
		public static const S_R_LOGIN:uint = 0;
		public static const S_B_HEARTBEAT:uint = 1;
		public static const S_B_DISPENSE:uint = 2;
		public static const S_B_TURN:uint = 3;
		public static const S_R_BET:uint = 4;
		public static const S_R_STAND:uint = 5;
		public static const S_R_SPLIT:uint = 6;
		public static const S_R_SURRENDER:uint = 7;
		public static const S_B_END:uint = 8;
		public static const S_R_START:uint = 9;
		public static const S_R_DOUBLE:uint = 10;
		public static const S_R_HIT:uint = 11;
		public static const S_B_ROUND_END:uint = 12;
		public static const S_R_INSURE:uint = 13;
		public static const S_B_FAKE_CARD:uint = 14;
	}

}