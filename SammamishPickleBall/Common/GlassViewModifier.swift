import SwiftUI
struct GlassViewModifier: ViewModifier {
    var cornerRadius: CGFloat
    init(cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
    }
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
extension View {
    /// Applies a "glassmorphism" effect to the view.
    /// - Parameter cornerRadius: The corner radius for the glass effect. Defaults to 20.
    /// - Returns: A view with the glassmorphism effect applied.
    func glass(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassViewModifier(cornerRadius: cornerRadius))
    }
}
#if DEBUG
struct GlassViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Hello, Glassmorphism!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(40)
                    .glass()
                HStack {
                    Text("Username")
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding()
                .glass(cornerRadius: 10)
                HStack {
                    Text("Password")
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding()
                .glass(cornerRadius: 10)
                Button(action: {}) {
                    Text("Sign In")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .glass(cornerRadius: 10)
                }
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif