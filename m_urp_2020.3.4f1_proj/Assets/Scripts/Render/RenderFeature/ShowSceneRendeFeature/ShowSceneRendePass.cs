using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections;
using System.Collections.Generic;

public class ShowSceneRendePass : ScriptableRenderPass
{
    private Material material;
    private float offset;
    private float offset_Y;
    private List<Vector3> list;
    private Material uiMat;
    private Mesh mesh;

    private Camera camera;

    private static int shaderId = Shader.PropertyToID("_MyRenderTexture");


    public ShowSceneRendePass(ShowSceneRendeFeature.ShowSceneRenderSetting setting)
    {
        this.renderPassEvent = setting.m_renderPassEvent;
        this.material = setting.m_material;
        this.offset = setting.offset;
        this.list = setting.list;
        this.uiMat = setting.m_UImaterial;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {

    }
    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {

        var cameraData = renderingData.cameraData;
        camera = cameraData.camera;

        var cmd = CommandBufferPool.Get("DrawShowScenePass");

        if (camera.name.Equals("CopyColorCamera"))
        {
            var source = cameraData.renderer.cameraColorTarget;
            var desctiptor = cameraData.cameraTargetDescriptor;

            cmd.GetTemporaryRT(shaderId, desctiptor);
            cmd.Blit(source, shaderId);
            cmd.SetGlobalTexture("_MyRenderTexture", shaderId);
        }
        if (camera.name.Equals("主摄像机_演示"))
        {
            DrawMainCamera(cameraData, context, cmd);
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }


    private void DrawMainCamera(CameraData cameraData, ScriptableRenderContext context, CommandBuffer cmd)
    {
        cmd.SetViewProjectionMatrices(Matrix4x4.identity, Matrix4x4.identity);
        cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, uiMat, 0, 0);
        if (mesh == null)
        {
            mesh = GameObject.Instantiate<Mesh>(RenderingUtils.fullscreenMesh);
            mesh.name = "CopyColorMesh";
        }
        mesh.SetVertices(list);
        cmd.DrawMesh(mesh, Matrix4x4.identity, material, 0, 0);
        cmd.SetViewProjectionMatrices(cameraData.camera.worldToCameraMatrix, cameraData.camera.projectionMatrix);
    }


    private List<Vector3> GetPosList()
    {
        var list = new List<Vector3>();

        list.Add(new Vector3(-1, -1, 0));
        list.Add(new Vector3(-1 + offset, 1, 0));
        list.Add(new Vector3(1 - offset, -1, 0));
        list.Add(new Vector3(1, 1, 0));
        return list;
    }

    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        if (camera.name.Equals("CopyColorCamera"))
        {
            cmd.ReleaseTemporaryRT(shaderId);
        }
    }
}
