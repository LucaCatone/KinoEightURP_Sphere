using UnityEngine;

[ExecuteAlways]
public class SphereDitherMatrix : MonoBehaviour
{
    private Camera cam;

    void Awake()
    {
        cam = Camera.main;
    }

    void Update()
    {
        if (cam == null) return;
        
        Transform t = cam.transform;
        float fovScale = Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);
        float aspect = (float)Screen.width / Screen.height;
        
        Shader.SetGlobalVector("_CameraRight",   t.right);
        Shader.SetGlobalVector("_CameraUp",      t.up);
        Shader.SetGlobalVector("_CameraForward", t.forward);
        Shader.SetGlobalFloat("_CameraFovScale", fovScale);
        Shader.SetGlobalFloat("_CameraAspect",   aspect);
    }
}
