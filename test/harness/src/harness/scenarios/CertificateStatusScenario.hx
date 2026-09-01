package harness.scenarios;

import openfl.security.CertificateStatus;

class CertificateStatusScenario {
	public static function run():Dynamic {
		return {
			expired: CertificateStatus.EXPIRED,
			invalid: CertificateStatus.INVALID,
			invalidChain: CertificateStatus.INVALID_CHAIN,
			notYetValid: CertificateStatus.NOT_YET_VALID,
			principalMismatch: CertificateStatus.PRINCIPAL_MISMATCH,
			revoked: CertificateStatus.REVOKED,
			trusted: CertificateStatus.TRUSTED,
			unknown: CertificateStatus.UNKNOWN,
			untrustedSigners: CertificateStatus.UNTRUSTED_SIGNERS
		};
	}
}
