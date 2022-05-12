using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CustormMesh
{
    [RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
    public class GenerateMesh : MonoBehaviour
    {
        MeshFilter m_meshFilter;
        Mesh m_mesh;
        public Material m_material;

        void OnEnable()
        {
            m_mesh = new Mesh();
            m_meshFilter = GetComponent<MeshFilter>();
            GetComponent<MeshRenderer>().material = m_material;

            m_meshFilter.mesh = m_mesh;
            m_mesh.name = "MyMesh";
            m_mesh.vertices = GetVertex();
            m_mesh.triangles = GetTriangles();
            m_mesh.uv = GetUVs();

        }

        private Vector2[] GetUVs()
        {
            return new Vector2[] { new Vector2(0, 0), new Vector2(0, 1), new Vector2(1, 1), new Vector2(1, 0) };
        }

        private Vector3[] GetVertex()
        {
            Vector3 x = new Vector3(0, 0, 0);
            Vector3 y = new Vector3(0, 1, 0);
            Vector3 z = new Vector3(1, 1, 0);
            Vector3 w = new Vector3(1, 0, 0);
            return new Vector3[] { x, y, z, w };
        }

        // 设置顶点的下标
        private int[] GetTriangles()
        {
            return new int[] { 0, 1, 2, 0, 2, 3 };
        }

    }

}
