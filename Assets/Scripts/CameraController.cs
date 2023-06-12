﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CameraController : SceneViewFilter
{
    private Material r_material;

    [SerializeField]
    private float r_maxDistance;
    [SerializeField]
    private Vector3 r_modInterval;
    [SerializeField]
    private Vector4 r_sphere;
    [SerializeField]
    private Vector4 r_box;
   // [SerializeField]
    private Vector4 r_sphere2;
    [SerializeField]
    private float r_boxSphereSmooth;
   // [SerializeField]
    private float r_boxRound;
   //[SerializeField]
    private float r_sphereIntersectSmooth;


    [Header("Light settings")]
    [SerializeField]
    private float r_shadowIntensity;
    [SerializeField]
    private float r_lightIntensity;
    [SerializeField]
    private Vector2 r_shadowDistance;
    [SerializeField]
    private Color r_lightColor;
    [SerializeField]
    private float r_shadowPenumbra;

    [SerializeField]
    private int r_maxIterations;
    [SerializeField]
    private float r_accuracy;

    [SerializeField]
    private Transform r_light;
    [SerializeField]
    private Color r_color;
    [SerializeField]
    private int r_ambientIterations;
    [SerializeField]
    private float r_ambientIntesity;
    [SerializeField]
    private float r_ambientSteps;
    [SerializeField]
    private Vector4 r_sphere4;

    [SerializeField]
    private float r_sphereSmooth;
    [SerializeField]
    private float r_degreeRotate;
    [SerializeField]
    private float r_rotationDegree;

    private int r_reflectionCount;
    private float r_reflectionIntensity;
    private float r_environmentIntensity;
    private Cubemap r_reflectionCube;

    [SerializeField]
    private Vector3 _mandleBrot1;
    [SerializeField]
    private Vector4 _mandleBrotColor1;
    [SerializeField]
    private float  _power;

    [SerializeField]
    private Shader r_shader;
    public Material raymarchingMaterial
    {
        get
        {
            if (!r_material && r_shader)
            {
                r_material = new Material(r_shader);
                r_material.hideFlags = HideFlags.HideAndDontSave;
            }
            return r_material;
        }
    }
    
    private Camera r_camera;
    public Camera raymarchingCamera {
        get { 
            if (!r_camera) {
                r_camera = GetComponent<Camera>();
            }
            return r_camera;
        }
    }
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!raymarchingMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        raymarchingMaterial.SetFloat("_power", _power);


        raymarchingMaterial.SetInt("r_maxIterations", r_maxIterations);
        raymarchingMaterial.SetFloat("r_accuracy", r_accuracy);
        raymarchingMaterial.SetColor("r_mainColor", r_color);
        raymarchingMaterial.SetVector("r_sphere", r_sphere);
        raymarchingMaterial.SetVector("r_box", r_box);
        raymarchingMaterial.SetVector("r_light", r_light ? r_light.forward : Vector3.down);
        
        raymarchingMaterial.SetColor("r_lightColor", r_lightColor);
        raymarchingMaterial.SetFloat("r_lightIntensity", r_lightIntensity);
        raymarchingMaterial.SetFloat("r_shadowIntensity", r_shadowIntensity);
        raymarchingMaterial.SetFloat("r_shadowPenumbra", r_shadowPenumbra);
        raymarchingMaterial.SetVector("r_shadowDistance", r_shadowDistance);
        raymarchingMaterial.SetInt("r_ambientIterations", r_ambientIterations);
        raymarchingMaterial.SetFloat("r_ambientSteps", r_ambientSteps);
        raymarchingMaterial.SetFloat("r_ambientIntesity", r_ambientIntesity);
        raymarchingMaterial.SetVector("r_sphere4", r_sphere4);
        raymarchingMaterial.SetFloat("r_sphereSmooth", r_sphereSmooth);
        raymarchingMaterial.SetFloat("r_degreeRotate", r_degreeRotate);

        raymarchingMaterial.SetMatrix("r_cameraFrustum", cameraFrustum(raymarchingCamera));
        raymarchingMaterial.SetMatrix("r_cameraToWorld", raymarchingCamera.cameraToWorldMatrix);
        raymarchingMaterial.SetFloat("r_maxdistance", r_maxDistance);
        raymarchingMaterial.SetVector("r_modInterval", r_modInterval);
        raymarchingMaterial.SetVector("r_sphere2", r_sphere2);
        raymarchingMaterial.SetFloat("r_boxRound", r_boxRound);
        raymarchingMaterial.SetFloat("r_boxSphereSmooth", r_boxSphereSmooth);
        raymarchingMaterial.SetFloat("r_sphereIntersectSmooth", r_sphereIntersectSmooth);

        raymarchingMaterial.SetInt("r_reflectionCount", r_reflectionCount);
        raymarchingMaterial.SetFloat("r_reflectionIntensity", r_reflectionIntensity);
        raymarchingMaterial.SetFloat("r_environmentIntensity", r_environmentIntensity);
        raymarchingMaterial.SetTexture("r_reflectionCube", r_reflectionCube);

        RenderTexture.active = destination;

        raymarchingMaterial.SetTexture("_MainTex", source);

        GL.PushMatrix();
        GL.LoadOrtho();
        raymarchingMaterial.SetPass(0);
        GL.Begin(GL.QUADS);

        //bottom left
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);
        //bottom right
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);
        //top right
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);
        // top left
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        GL.End();
        GL.PopMatrix();
    }

    private Matrix4x4 cameraFrustum(Camera camera)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fieldOfView = Mathf.Tan((camera.fieldOfView * 0.5f) * Mathf.Deg2Rad);

        Vector3 r_UP = Vector3.up * fieldOfView;
        Vector3 r_RIGHT = Vector3.right * fieldOfView * camera.aspect;
        Vector3 r_BOTTOMLEFT = (-Vector3.forward - r_RIGHT - r_UP);
        Vector3 r_BOTTOMRIGHT = (-Vector3.forward + r_RIGHT - r_UP);
        Vector3 r_TOPLEFT = (-Vector3.forward - r_RIGHT + r_UP);
        Vector3 r_TOPRIGHT = (-Vector3.forward + r_RIGHT + r_UP);

        frustum.SetRow(3, r_BOTTOMLEFT);
        frustum.SetRow(2, r_BOTTOMRIGHT);
        frustum.SetRow(1, r_TOPRIGHT);
        frustum.SetRow(0, r_TOPLEFT);
       

        return frustum;
    }
}
