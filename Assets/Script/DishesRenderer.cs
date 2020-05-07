using System.Collections;
using System.Collections.Generic;
using UnityEngine;



[ExecuteInEditMode]
public class DishesRenderer : MonoBehaviour {
    
	public enum ProcessType {none=0,fry,stir,boil}
    public Material[] _ProcessMaterials = new Material[4];
    private Material[] _UsedMaterials = new Material[10]; 
    private int _StartRenderQueue = 3000;
    private Material _InstanceMaterial;
    private static string _MaterialsPath = "Assets/Materials/Temp";
    private List<ProcessType> _ProcessTags = new List<ProcessType>();


//增加加工步骤
	public void AddProcess(ProcessType _processtype){
        Debug.Log("Start:"+_InstanceMaterial);
        Debug.Log(1);
        CreateMaterial(_processtype);
		this._ProcessTags.Add(_processtype);
        _UsedMaterials[(int)_ProcessTags.Count-1] = _InstanceMaterial;
        this.GetComponent<Renderer>().materials = _UsedMaterials;
	}
//去掉加工步骤
    public void RemoveProcess()
    {
        this._ProcessTags.RemoveAt(_ProcessTags.Count-1);
        _UsedMaterials[(int)_ProcessTags.Count] = null;
        this.GetComponent<Renderer>().materials = _UsedMaterials;
        _StartRenderQueue--;
        
    }

//材质动态创建
    private void CreateMaterial(ProcessType _processtype){
        _InstanceMaterial = new Material(Shader.Find("Legacy Shaders/Transparent/Bumped Specular"));
        Debug.Log("New:"+_InstanceMaterial);
        _InstanceMaterial.CopyPropertiesFromMaterial(_ProcessMaterials[(int)_processtype]);
        Debug.Log("After:"+_InstanceMaterial);
        _InstanceMaterial.renderQueue= _StartRenderQueue++;
    }
}
