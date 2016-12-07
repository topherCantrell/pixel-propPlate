package propNeoPixel;

public class Tests {

public static void main(String[] args) throws Exception {
		
		NEOStrip strip = new NEOStrip("COM7");
		
		strip.clear();
		
		for(int x=0;x<144;++x) {
			strip.set(x,x%32);			
		}		
		strip.draw();	
		
	}

}
