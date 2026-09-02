package harness;

import harness.scenarios.BitmapDataScenario;
import harness.scenarios.ByteArrayScenario;
import harness.scenarios.CertificateStatusScenario;
import harness.scenarios.ClipboardScenario;
import harness.scenarios.ColorTransformScenario;
import harness.scenarios.DateTimeFormatterScenario;
import harness.scenarios.DatagramSocketScenario;
import harness.scenarios.DictionaryScenario;
import harness.scenarios.DesktopScenario;
import harness.scenarios.Display3DScenario;
import harness.scenarios.DisplayBoundsScenario;
import harness.scenarios.DisplayContainerScenario;
import harness.scenarios.DisplayHitTestScenario;
import harness.scenarios.DisplayObjectScenario;
import harness.scenarios.DisplayObjectPropertyEdgesScenario;
import harness.scenarios.DisplayTransformScenario;
import harness.scenarios.ErrorScenario;
import harness.scenarios.ErrorSubclassesScenario;
import harness.scenarios.EventConstructionScenario;
import harness.scenarios.EventDispatcherCaptureScenario;
import harness.scenarios.EventDispatcherScenario;
import harness.scenarios.EventSubclassesScenario;
import harness.scenarios.EventPropagationScenario;
import harness.scenarios.EventRedispatchScenario;
import harness.scenarios.ExternalInterfaceScenario;
import harness.scenarios.FileReferenceScenario;
import harness.scenarios.FilterScenario;
import harness.scenarios.FontAndStyleScenario;
import harness.scenarios.GameInputScenario;
import harness.scenarios.GraphicsDrawScenario;
import harness.scenarios.GraphicsDataScenario;
import harness.scenarios.InteractiveObjectScenario;
import harness.scenarios.KeyboardScenario;
import harness.scenarios.LocaleIDScenario;
import harness.scenarios.LoaderScenario;
import harness.scenarios.LoaderInfoScenario;
import harness.scenarios.Matrix3DScenario;
import harness.scenarios.MatrixScenario;
import harness.scenarios.MouseScenario;
import harness.scenarios.MovieClipScenario;
import harness.scenarios.MultitouchScenario;
import harness.scenarios.NativeApplicationScenario;
import harness.scenarios.ObjectPoolScenario;
import harness.scenarios.PermissionStatusScenario;
import harness.scenarios.PointScenario;
import harness.scenarios.RectangleScenario;
import harness.scenarios.ScreenWindowScenario;
import harness.scenarios.SensorScenario;
import harness.scenarios.ShaderTypesScenario;
import harness.scenarios.SimpleButtonScenario;
import harness.scenarios.SystemScenario;
import harness.scenarios.ShapeBitmapScenario;
import harness.scenarios.SharedObjectScenario;
import harness.scenarios.SoundStateScenario;
import harness.scenarios.SoundLifecycleScenario;
import harness.scenarios.SocketScenario;
import harness.scenarios.SpriteScenario;
import harness.scenarios.StageScenario;
import harness.scenarios.StageTextScenario;
import harness.scenarios.StaticTextScenario;
import harness.scenarios.StyleSheetScenario;
import harness.scenarios.TelemetryScenario;
import harness.scenarios.TextFieldScenario;
import harness.scenarios.TextFieldBehaviorScenario;
import harness.scenarios.TextFormatScenario;
import harness.scenarios.TimerScenario;
import harness.scenarios.TilesScenario;
import harness.scenarios.TransformScenario;
import harness.scenarios.Utils3DScenario;
import harness.scenarios.URLLoaderScenario;
import harness.scenarios.URLStreamScenario;
import harness.scenarios.URLTypesScenario;
import harness.scenarios.Vector3DScenario;
import harness.scenarios.VideoScenario;
import harness.scenarios.XMLSocketScenario;

class Scenarios {
	public static function all():Array<Scenario> {
		return [
			{
				name: "utils/object-pool",
				run: ObjectPoolScenario.run
			},
			{
				name: "utils/timer",
				run: TimerScenario.run
			},
			{
				name: "events/redispatch",
				run: EventRedispatchScenario.run
			},
			{
				name: "events/propagation",
				run: EventPropagationScenario.run
			},
			{
				name: "geom/point",
				run: PointScenario.run
			},
			{
				name: "display/bounds",
				run: DisplayBoundsScenario.run
			},
			{
				name: "display/graphics-draw",
				run: GraphicsDrawScenario.run
			},
			{
				name: "display/graphics-data",
				run: GraphicsDataScenario.run
			},
			{
				name: "display/hit-test",
				run: DisplayHitTestScenario.run
			},
			{
				name: "display/transform",
				run: DisplayTransformScenario.run
			},
			{
				name: "geom/rectangle",
				run: RectangleScenario.run
			},
			{
				name: "geom/matrix",
				run: MatrixScenario.run
			},
			{
				name: "geom/vector3d",
				run: Vector3DScenario.run
			},
			{
				name: "geom/color-transform",
				run: ColorTransformScenario.run
			},
			{
				name: "geom/matrix3d",
				run: Matrix3DScenario.run
			},
			{
				name: "geom/utils3d",
				run: Utils3DScenario.run
			},
			{
				name: "display/screen-window",
				run: ScreenWindowScenario.run
			},
			{
				name: "display/shader-types",
				run: ShaderTypesScenario.run
			},
			{
				name: "display/shape-bitmap",
				run: ShapeBitmapScenario.run
			},
			{
				name: "display/loader",
				run: LoaderScenario.run
			},
			{
				name: "display/loader-info",
				run: LoaderInfoScenario.run
			},
			{
				name: "display/stage",
				run: StageScenario.run
			},
			{
				name: "display3d/core",
				run: Display3DScenario.run
			},
			{
				name: "display/movie-clip",
				run: MovieClipScenario.run
			},
			{
				name: "display/tiles",
				run: TilesScenario.run
			},
			{
				name: "media/sound-state",
				run: SoundStateScenario.run
			},
			{
				name: "media/sound-lifecycle",
				run: SoundLifecycleScenario.run
			},
			{
				name: "media/video",
				run: VideoScenario.run
			},
			{
				name: "errors/error",
				run: ErrorScenario.run
			},
			{
				name: "errors/subclasses",
				run: ErrorSubclassesScenario.run
			},
			{
				name: "events/construction",
				run: EventConstructionScenario.run
			},
			{
				name: "events/dispatcher",
				run: EventDispatcherScenario.run
			},
			{
				name: "events/dispatcher-capture",
				run: EventDispatcherCaptureScenario.run
			},
			{
				name: "events/subclasses",
				run: EventSubclassesScenario.run
			},
			{
				name: "globalization/date-time-formatter",
				run: DateTimeFormatterScenario.run
			},
			{
				name: "globalization/locale-id",
				run: LocaleIDScenario.run
			},
			{
				name: "external/external-interface",
				run: ExternalInterfaceScenario.run
			},
			{
				name: "permissions/permission-status",
				run: PermissionStatusScenario.run
			},
			{
				name: "sensors/core",
				run: SensorScenario.run
			},
			{
				name: "profiler/telemetry",
				run: TelemetryScenario.run
			},
			{
				name: "security/certificate-status",
				run: CertificateStatusScenario.run
			},
			{
				name: "net/url-loader-request",
				run: URLLoaderScenario.run
			},
			{
				name: "net/url-stream",
				run: URLStreamScenario.run
			},
			{
				name: "net/url-types",
				run: URLTypesScenario.run
			},
			{
				name: "net/file-reference",
				run: FileReferenceScenario.run
			},
			{
				name: "net/shared-object",
				run: SharedObjectScenario.run
			},
			{
				name: "net/socket-basics",
				run: SocketScenario.run
			},
			{
				name: "net/datagram-socket",
				run: DatagramSocketScenario.run
			},
			{
				name: "net/xml-socket",
				run: XMLSocketScenario.run
			},
			{
				name: "display/display-object",
				run: DisplayObjectScenario.run
			},
			{
				name: "display/interactive-object",
				run: InteractiveObjectScenario.run
			},
			{
				name: "display/sprite",
				run: SpriteScenario.run
			},
			{
				name: "display/simple-button",
				run: SimpleButtonScenario.run
			},
			{
				name: "display/property-edges",
				run: DisplayObjectPropertyEdgesScenario.run
			},
			{
				name: "display/container",
				run: DisplayContainerScenario.run
			},
			{
				name: "display/bitmap-data",
				run: BitmapDataScenario.run
			},
			{
				name: "filters/properties",
				run: FilterScenario.run
			},
			{
				name: "text/text-field",
				run: TextFieldScenario.run
			},
			{
				name: "text/stage-text",
				run: StageTextScenario.run
			},
			{
				name: "text/static-text",
				run: StaticTextScenario.run
			},
			{
				name: "text/style-sheet",
				run: StyleSheetScenario.run
			},
			{
				name: "text/text-field-behavior",
				run: TextFieldBehaviorScenario.run
			},
			{
				name: "text/text-format",
				run: TextFormatScenario.run
			},
			{
				name: "text/font-and-style",
				run: FontAndStyleScenario.run
			},
			{
				name: "geom/transform",
				run: TransformScenario.run
			},
			{
				name: "system/capabilities",
				run: SystemScenario.run
			},
			{
				name: "desktop/native-window",
				run: DesktopScenario.run
			},
			{
				name: "desktop/native-application",
				run: NativeApplicationScenario.run
			},
			{
				name: "desktop/clipboard",
				run: ClipboardScenario.run
			},
			{
				name: "ui/keyboard",
				run: KeyboardScenario.run
			},
			{
				name: "ui/mouse",
				run: MouseScenario.run
			},
			{
				name: "ui/game-input",
				run: GameInputScenario.run
			},
			{
				name: "ui/multitouch",
				run: MultitouchScenario.run
			},
			{
				name: "utils/byte-array",
				run: ByteArrayScenario.run
			},
			{
				name: "utils/dictionary",
				run: DictionaryScenario.run
			}
		];
	}
}
