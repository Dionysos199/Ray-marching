//Plane
float sdPlane( float3 p, float3 n, float h )
{
  // n must be normalized
  return dot(p,n) + h;
}


// Sphere
// s: radius
float sdSphere(float3 p, float s)
{
	return length(p) - s;
}

// Box
// b: size of box in x/y/z
float sdBox(float3 p, float3 b)
{
	float3 d = abs(p) - b;
	return min(max(d.x, max(d.y, d.z)), 0.0) +
		length(max(d, 0.0));
}

float sdRoundBox(in float3 p, float3 b, float r){
    float3 q= abs(p)-b;

    return min (max(q.x, max(q.y,q.z)), 0.0) +length(max(q, 0.0))-r;
}

// BOOLEAN OPERATORS //

// Union
float opU(float d1, float d2)
{
	return min(d1, d2);
}

// Subtraction
float opS(float d1, float d2)
{
	return max(-d1, d2);
}

// Intersection
float opI(float d1, float d2)
{
	return max(d1, d2);
}


float4 opUS( float4 d1, float4 d2, float k ) 
{
    float h = clamp( 0.5 + 0.5*(d2.w-d1.w)/k, 0.0, 1.0 );
 float3 color = lerp(d2.rgb, d1.rgb, h);
    float dist = lerp( d2.w, d1.w, h ) - k*h*(1.0-h); 
 return float4(color,dist);
}

float opSS( float d1, float d2, float k ) 
{
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h); 
}

float opIS( float d1, float d2, float k ) 
{
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h); 
}


// Mod Position Axis
float pMod1 (inout float p, float size)
{
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(-p+halfsize,size)-halfsize;
	return c;
}

float sdCappedTorus( float3 p, float2 sc, float ra, float rb)
{
  p.x = abs(p.x);
  float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
  return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

float sdCone( float3 p, float2 c )
{
    // c is the sin/cos of the angle
    float2 q = float2( length(p.xz), -p.y );
    float d = length(q-c*max(dot(q,c), 0.0));
    return d * ((q.x*c.y-q.y*c.x<0.0)?-1.0:1.0);
}

float sdHexPrism( float3 p, float2 h )
{
  const float3 k = float3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
  float2 d = float2(
       length(p.xy-float2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
       p.z-h.y );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdCappedCylinder( float3 p, float h, float r )
{
  float2 d = abs(float2(length(p.xz),p.y)) - float2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}




float mandleBulb( in float3 p, out float4 resColor )
{
    float3 w = p;
    float m = dot(w,w);

    float4 trap = float4(abs(w),m);
	float dz = 1.0;
    
	for( int i=0; i<1024; i++ )
    {

        // trigonometric version (MUCH faster than polynomial)
        
        // dz = 8*z^7*dz
		dz = 8.0*pow(m,3.5)*dz + 1.0;
      
        // z = z^8+c
        float r = length(w);
        float b = 8.0*acos( w.y/r);
        float a = 8.0*atan2( w.x, w.z );
        w = p + pow(r,8.0) * float3( sin(b)*sin(a), cos(b), sin(b)*cos(a) );
    
        
        trap = min( trap, float4(abs(w),m) );

        m = dot(w,w);
		if( m > 512.0 )
            break;
    }

    resColor = float4(m,trap.yzw);

    // distance estimation (through the Hubbard-Douady potential)
    return 0.25*log(m)*sqrt(m)/dz;
}

float sdEllipsoid( in float3 p, in float3 r )
{
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}


   float smin( float a, float b, float k )
            {
                float h = max(k-abs(a-b),0.0);
                return min(a, b) - h*h*0.25/k;

            }


                       float mb(float3 p) {
	            p.xyz = p.xzy;
	            float3 z = p;
	            float3 dz=float3(0,0,0);
	            float power = 8.0;
	            float r, theta, phi;
	            float dr = 1.0;
	
	            float t0 = 1.0;
	            for(int i = 0; i < 7; ++i) {
		            r = length(z);
		            if(r > 2.0) continue;
		            theta = atan2(z.y , z.x);
                   phi = asin(z.z / r) + _Time.y*0.1;
                    dr = pow(r, power - 1.0) * dr * power + 1.0;
	
		            r = pow(r, power);
		            theta = theta * power;
		            phi = phi * power;
		
		            z = r * float3(cos(theta)*cos(phi), sin(theta)*cos(phi), sin(phi)) + p;
		
		            t0 = min(t0, r);
	        }
	            return float(0.5 * log(r) * r / dr);
            }
