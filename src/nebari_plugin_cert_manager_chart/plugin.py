from typing import Any, Dict, List, Optional
import os

from nebari.schema import Base
from _nebari.stages.base import NebariTerraformStage

class CertManagerConfig(Base):
    name: Optional[str] = "cert-manager"
    namespace: Optional[str] = None
    email: Optional[str] = None
    solver: Optional[str] = None
    components_namespace: Optional[str] = None
    staging: Optional[str] = None
    certificates: Optional[List[Any]] = []
    issuers: Optional[List[Any]] = []
    values: Optional[Dict[str, Any]] = {}

class InputSchema(Base):
    cert_manager: CertManagerConfig = CertManagerConfig()

class CertManagerStage(NebariTerraformStage):
    name = "cert-manager"
    priority = 100

    input_schema = InputSchema

    def input_vars(self, stage_outputs: Dict[str, Dict[str, Any]]):
        domain = stage_outputs["stages/04-kubernetes-ingress"]["domain"]
        zone = ".".join(domain.split(".")[-2:])
        chart_ns = self.config.cert_manager.namespace
        create_ns = True
        if chart_ns == None or chart_ns == "" or chart_ns == self.config.namespace:
            chart_ns = self.config.namespace
            create_ns = False
        comp_ns = self.config.cert_manager.components_namespace
        create_comp_ns = True
        if comp_ns == None or comp_ns == "" or comp_ns == self.config.cert_manager.namespace:
            comp_ns = self.config.cert_manager.namespace
            create_comp_ns = False

        return {
            "name": self.config.cert_manager.name,
            "domain": domain,
            "zone": zone,
            "create_namespace": create_ns,
            "namespace": chart_ns,
            "create_components_namespace": create_comp_ns,
            "comp_namespace": comp_ns,
            "email": self.config.cert_manager.email,
            "solver": self.config.cert_manager.solver,
            "staging": self.config.cert_manager.staging.lower().capitalize() == "True",
            "certificates": self.config.cert_manager.certificates,
            "apikey": os.environ.get("CLOUDFLARE_TOKEN", ""),
            "issuers": self.config.cert_manager.issuers,
            "overrides": self.config.cert_manager.values
        }
        