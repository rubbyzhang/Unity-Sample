using UnityEngine;
using System.Collections;
 
[ExecuteInEditMode]
public class MirrorReflection : MonoBehaviour
{
    static bool GInsideRendering = false;

    public int            TextureSize         = 256;
    public float          ClipPlaneOffset     = 0.07f;
    public LayerMask      ReflectLayers       = -1;
    public float          BlurSpread          = 1;

    public Renderer[]     Renderers;

    [HideInInspector]
    public Shader         ReflectionShader;

    [HideInInspector]
    public Material       DownSampleMaterial;
 
    public void OnWillRenderObject()
    {
        /*
        var renderer = GetComponent<Renderer>();

        if( !enabled || !renderer || !renderer.sharedMaterial || !renderer.enabled )
            return;

		if (renderer.sharedMaterial.IsKeywordEnabled ("REALTIMEREFLECTION_ON") == false)
			return;
        */

        if (Renderers == null || Renderers.Length <=0)
            return;

        var camera = Camera.current;
        if (!camera) 
        {
            return;
        }
 
        // Avoid recursive reflections.
        if( GInsideRendering )
            return;
        
        GInsideRendering = true;
        {
            // Reflection render texture
            if (!mReflectionTexture || OldReflectionRTSize != TextureSize)
            {
                if (mReflectionTexture)
                {
                    DestroyImmediate(mReflectionTexture);
                }

                mReflectionTexture = new RenderTexture(TextureSize/2, TextureSize/2, 0);
                mReflectionTexture.name = "__MirrorReflRender" + GetInstanceID();
                mReflectionTexture.isPowerOfTwo = true;
                mReflectionTexture.hideFlags = HideFlags.DontSave;
                mReflectionTexture.filterMode = FilterMode.Bilinear;
                OldReflectionRTSize = TextureSize;
            }

            // Camera for reflection
            if (!mReflectionCamera)
            {
                var go = new GameObject("__MirrorReflCamera" + GetInstanceID() + " for " + camera.GetInstanceID(), typeof(Camera), typeof(Skybox));
                mReflectionCamera = go.GetComponent<Camera>();
                mReflectionCamera.enabled = false;
                mReflectionCamera.transform.position = transform.position;
                mReflectionCamera.transform.rotation = transform.rotation;
				mReflectionCamera.clearFlags |= CameraClearFlags.SolidColor;
                go.hideFlags = HideFlags.HideAndDontSave;
            }

            RenderReflection(camera, Renderers);
        }
        GInsideRendering = false;
    }
  
    void OnDisable()
    {
        if( mReflectionTexture ) 
        {
            DestroyImmediate( mReflectionTexture );
            mReflectionTexture = null;
        }

        if (mReflectionCamera) 
        {
            DestroyImmediate (mReflectionCamera);
        }
    }
 
    static float sgn(float a)
    {
        if (a > 0.0f) return 1.0f;
        if (a < 0.0f) return -1.0f;
        return 0.0f;
    }
    
#if UNITY_EDITOR
	void OnValidate()
	{
		Reset();
	}
	void Reset()
	{
		if (ReflectionShader == null) 
		{
			ReflectionShader = Shader.Find("BlueWar/NPRLitToonTextureUnlit");
		}

        if (DownSampleMaterial == null)
        {
            DownSampleMaterial = UnityEditor.AssetDatabase.LoadAssetAtPath<Material>("Assets/Shaders/MobileBlur.mat");
        }
	}
#endif

    static public void Blit( Texture source, RenderTexture rt, Material mat, int pass)
    {
        var oldRT = RenderTexture.active;

        RenderTexture.active = rt;
        GL.PushMatrix();
        GL.LoadOrtho();
        mat.SetTexture("_MainTex", source);
        mat.SetPass(pass);
        GL.Begin(GL.QUADS);
            GL.TexCoord2(0.0f, 1.0f); GL.Vertex3(0.0f, 1.0f, 0.1f);
            GL.TexCoord2(1.0f, 1.0f); GL.Vertex3(1.0f, 1.0f, 0.1f);                
            GL.TexCoord2(1.0f, 0.0f); GL.Vertex3(1.0f, 0.0f, 0.1f);                
            GL.TexCoord2(0.0f, 0.0f); GL.Vertex3(0.0f, 0.0f, 0.1f);                
            GL.End();
        GL.PopMatrix();
        RenderTexture.active = oldRT;
    }

    void RenderReflection(Camera camera, Renderer[] renderers)
    {
        var p = transform.position;
        var n = transform.up;

        var oldPixelLightCount = QualitySettings.pixelLightCount;
        if (true)
        {
            QualitySettings.pixelLightCount = 0;
        }

		mReflectionCamera.clearFlags = CameraClearFlags.SolidColor;
        mReflectionCamera.backgroundColor = camera.backgroundColor;
        mReflectionCamera.farClipPlane = camera.farClipPlane;
        mReflectionCamera.nearClipPlane = camera.nearClipPlane;
        mReflectionCamera.orthographic = camera.orthographic;
        mReflectionCamera.fieldOfView = camera.fieldOfView;
        mReflectionCamera.aspect = camera.aspect;
        mReflectionCamera.orthographicSize = camera.orthographicSize;

        var reflectionPlane = new Vector4(n.x, n.y, n.z, -Vector3.Dot(n, p) - ClipPlaneOffset);
        var reflection = Matrix4x4.zero;
        CalculateReflectionMatrix(ref reflection, reflectionPlane);

        var oldpos = camera.transform.position;
        var newpos = reflection.MultiplyPoint(oldpos);
        mReflectionCamera.worldToCameraMatrix = camera.worldToCameraMatrix * reflection;

        var projection = camera.projectionMatrix;
        CalculateObliqueMatrix(ref projection, CameraSpacePlane(mReflectionCamera, p, n, 1.0f));
        mReflectionCamera.projectionMatrix = projection;

        mReflectionCamera.cullingMask = ~(1 << 4) & ReflectLayers.value;
        var tempRT = RenderTexture.GetTemporary(TextureSize, TextureSize, 16);
        mReflectionCamera.targetTexture = tempRT;
        GL.SetRevertBackfacing(true);
            mReflectionCamera.transform.position = newpos;
            var euler = camera.transform.eulerAngles;
            mReflectionCamera.transform.eulerAngles = new Vector3(0, euler.y, euler.z);
            mReflectionCamera.RenderWithShader(ReflectionShader, "RenderType");
            mReflectionCamera.transform.position = oldpos;
        GL.SetRevertBackfacing(false);

        DownSampleMaterial.SetVector("_Parameter", new Vector4(BlurSpread, BlurSpread, 0, 0));
        mReflectionTexture.DiscardContents();

        Blit(tempRT, mReflectionTexture, DownSampleMaterial, 5);
        mReflectionCamera.targetTexture = mReflectionTexture;
        RenderTexture.ReleaseTemporary(tempRT);
    
        // Set matrix on the shader that transforms UVs from object space into screen space. We want to just project reflection texture on screen.
        var scaleOffset = Matrix4x4.TRS(new Vector3(0.5f, 0.5f, 0.5f), Quaternion.identity, new Vector3(0.5f, 0.5f, 0.5f));
        var scale = transform.lossyScale;

        var mtx = transform.localToWorldMatrix *
            Matrix4x4.Scale(new Vector3(1.0f / scale.x, 1.0f / scale.y, 1.0f / scale.z)) *
            Matrix4x4.TRS(Vector3.zero, Quaternion.Inverse(transform.rotation), Vector3.one) *
            Matrix4x4.TRS(-transform.position, Quaternion.identity, Vector3.one);
        mtx = scaleOffset * camera.projectionMatrix * camera.worldToCameraMatrix * mtx;

        for(var i = 0; i < renderers.Length; ++i)
        {
            if (renderers[i] == null)
                continue;

            renderers[i].sharedMaterial.SetTexture("_ReflectionTex", mReflectionTexture);
            renderers[i].sharedMaterial.SetMatrix("_ProjMatrix", mtx);
        }

        // Restore pixel light count
        if (true)
        {
            QualitySettings.pixelLightCount = oldPixelLightCount;
        }
    }
 
    Vector4 CameraSpacePlane (Camera cam, Vector3 pos, Vector3 normal, float sideSign)
    {
        Vector3 offsetPos = pos + normal * ClipPlaneOffset;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint( offsetPos );
        Vector3 cnormal = m.MultiplyVector( normal ).normalized * sideSign;
        return new Vector4( cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos,cnormal) );
    }
 
    // http://aras-p.info/texts/obliqueortho.html
    static void CalculateObliqueMatrix (ref Matrix4x4 projection, Vector4 clipPlane)
    {
        Vector4 q = projection.inverse * new Vector4(sgn(clipPlane.x), sgn(clipPlane.y), 1.0f, 1.0f);
        Vector4 c = clipPlane * (2.0F / (Vector4.Dot (clipPlane, q)));

        // third row = clip plane - fourth row
        projection[2]  = c.x - projection[ 3];
        projection[6]  = c.y - projection[ 7];
        projection[10] = c.z - projection[11];
        projection[14] = c.w - projection[15];
    }
 
    static void CalculateReflectionMatrix (ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F*plane[0]*plane[0]);
        reflectionMat.m01 = (   - 2F*plane[0]*plane[1]);
        reflectionMat.m02 = (   - 2F*plane[0]*plane[2]);
        reflectionMat.m03 = (   - 2F*plane[3]*plane[0]);
 
        reflectionMat.m10 = (   - 2F*plane[1]*plane[0]);
        reflectionMat.m11 = (1F - 2F*plane[1]*plane[1]);
        reflectionMat.m12 = (   - 2F*plane[1]*plane[2]);
        reflectionMat.m13 = (   - 2F*plane[3]*plane[1]);
 
        reflectionMat.m20 = (   - 2F*plane[2]*plane[0]);
        reflectionMat.m21 = (   - 2F*plane[2]*plane[1]);
        reflectionMat.m22 = (1F - 2F*plane[2]*plane[2]);
        reflectionMat.m23 = (   - 2F*plane[3]*plane[2]);
 
        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;
    }

    private Camera        mReflectionCamera = null;
    private RenderTexture mReflectionTexture = null;
    private int           OldReflectionRTSize = 0;
}