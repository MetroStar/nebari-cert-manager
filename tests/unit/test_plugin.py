from src.nebari_plugin_cert_manager_chart.plugin import CertManagerStage, CertManagerConfig, InputSchema

class TestConfig(InputSchema):
    namespace: str

def test_ctor():
    sut = CertManagerStage(output_directory = None, config = None)
    assert sut.priority == 100

def test_input_vars():
    config = TestConfig(namespace = "nebari-ns")
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["namespace"] == "cert-manager"
    assert result["solver"] == "cloudflare"
    assert result["comp_namespace"] == "onyx"
    assert result["staging"] == False

def test_default_namespace():
    config = TestConfig(namespace = "nebari-ns")
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["namespace"] == "cert-manager"

def test_chart_namespace():
    config = TestConfig(namespace = "nebari-ns", cert_manager = CertManagerConfig(namespace = "cert-manager-ns"))
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["create_namespace"] == True
    assert result["namespace"] == "cert-manager-ns"

def test_chart_overrides():
    config = TestConfig(namespace = "nebari-ns", cert_manager = CertManagerConfig(values = { "foo": "bar" }))
    sut = CertManagerStage(output_directory = None, config = config)

    stage_outputs = get_stage_outputs()
    result = sut.input_vars(stage_outputs)
    assert result["overrides"] == { "foo": "bar" }

def get_stage_outputs():
    return {
        "stages/04-kubernetes-ingress": {
            "domain": "my-test-domain.com"
        }
    }