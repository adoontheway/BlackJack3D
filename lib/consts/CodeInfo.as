package consts 
{
	/**
	 * ...
	 * @author jerry.d
	 */
	public class CodeInfo 
	{
		
		public function CodeInfo() 
		{
			
		}
		private static const codeInfo:Object = {
			0 : 'Success',
			1 : 'Wrong info',
			2 : 'Lack Balance',
			3 : 'Can not do this action',
			4 : 'Bet first',
			5 : 'Wrong Password'
		};
		public static function getInfo(code:uint):String{
			if( codeInfo[code])
				return codeInfo[code];
			else
				return 'unknow error with code ['+code+']';
		}
	}

}