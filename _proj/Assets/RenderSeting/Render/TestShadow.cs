using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEditor;

public class TestShadow : MonoBehaviour
{
    public float distance = 10;
    private UniversalRenderPipelineAsset assets;

    // Start is called before the first frame update
    void Start()
    {

        // assets = new UniversalRenderPipelineAsset();

    }

    // Update is called once per frame
    void Update()
    {
        RenderingData data = new RenderingData();
        data.cameraData.maxShadowDistance = 90;
        // assets.shadowDistance = distance;
        // assets.useSRPBatcher = false;

        // AssetDatabase.SaveAssets();
    }
}
