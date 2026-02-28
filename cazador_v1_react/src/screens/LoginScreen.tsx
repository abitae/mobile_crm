import React from 'react';
import {
  View,
  Text,
  TextInput,
  Pressable,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
} from 'react-native';
import { User, ShieldCheck, ChevronRight } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';

interface LoginScreenProps {
  username: string;
  setUsername: (v: string) => void;
  pin: string[];
  isLoggingIn: boolean;
  loginError: string;
  onPinChange: (index: number, value: string) => void;
  onLogin: () => void;
}

export function LoginScreen({
  username,
  setUsername,
  pin,
  isLoggingIn,
  loginError,
  onPinChange,
  onLogin,
}: LoginScreenProps) {
  const canSubmit = username.trim().length > 0 && pin.every((d) => d !== '');

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <View style={styles.bgBlur1} />
      <View style={styles.bgBlur2} />
      <View style={styles.content}>
        <View style={styles.header}>
          <View style={styles.logoIcon}>
            <ShieldCheck size={32} color={colors.white} />
          </View>
          <Text style={styles.title}>Veridian Mobile</Text>
          <Text style={styles.subtitle}>
            Ingresa tus credenciales para continuar
          </Text>
        </View>

        <View style={styles.form}>
          <View style={styles.inputWrap}>
            <User
              size={18}
              color={colors.zinc[400]}
              style={styles.inputIcon}
            />
            <TextInput
              style={styles.input}
              placeholder="Usuario"
              placeholderTextColor={colors.zinc[400]}
              value={username}
              onChangeText={setUsername}
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>

          <Text style={styles.pinLabel}>PIN de 6 dígitos</Text>
          <View style={styles.pinRow}>
            {pin.map((digit, i) => (
              <TextInput
                key={i}
                style={styles.pinInput}
                value={digit}
                onChangeText={(v) => onPinChange(i, v)}
                keyboardType="number-pad"
                maxLength={1}
                secureTextEntry
              />
            ))}
          </View>

          {loginError ? (
            <Text style={styles.error}>{loginError}</Text>
          ) : null}

          <Pressable
            onPress={onLogin}
            disabled={isLoggingIn || !canSubmit}
            style={({ pressed }) => [
              styles.submitBtn,
              (!canSubmit || isLoggingIn) && styles.submitBtnDisabled,
              pressed && canSubmit && styles.submitBtnPressed,
            ]}
          >
            {isLoggingIn ? (
              <ActivityIndicator size="small" color={colors.white} />
            ) : (
              <>
                <Text style={styles.submitText}>Iniciar Sesión</Text>
                <ChevronRight size={18} color={colors.white} />
              </>
            )}
          </Pressable>
          <Text style={styles.hint}>Pista: demo / 123456</Text>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xxl,
  },
  bgBlur1: {
    position: 'absolute',
    top: '-10%',
    left: '-10%',
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: colors.emerald[100],
    opacity: 0.5,
  },
  bgBlur2: {
    position: 'absolute',
    bottom: '-10%',
    right: '-10%',
    width: 240,
    height: 240,
    borderRadius: 120,
    backgroundColor: colors.blue[100],
    opacity: 0.5,
  },
  content: { width: '100%', maxWidth: 400 },
  header: { alignItems: 'center', marginBottom: 40 },
  logoIcon: {
    width: 64,
    height: 64,
    borderRadius: borderRadius.lg,
    backgroundColor: colors.emerald[500],
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.lg,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    color: colors.zinc[900],
    marginBottom: spacing.sm,
  },
  subtitle: { fontSize: 14, color: colors.zinc[500] },
  form: { gap: spacing.lg },
  inputWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.zinc[50],
    borderWidth: 1,
    borderColor: colors.zinc[200],
    borderRadius: borderRadius.xl,
    paddingHorizontal: spacing.lg,
  },
  inputIcon: { marginRight: spacing.md },
  input: {
    flex: 1,
    paddingVertical: 14,
    fontSize: 16,
    color: colors.zinc[900],
  },
  pinLabel: {
    fontSize: 10,
    fontWeight: '700',
    color: colors.zinc[400],
    letterSpacing: 2,
    marginLeft: 4,
  },
  pinRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: spacing.sm,
  },
  pinInput: {
    flex: 1,
    aspectRatio: 1,
    backgroundColor: colors.zinc[50],
    borderWidth: 1,
    borderColor: colors.zinc[200],
    borderRadius: borderRadius.xl,
    textAlign: 'center',
    fontSize: 18,
    fontWeight: '700',
    color: colors.zinc[900],
  },
  error: {
    textAlign: 'center',
    fontSize: 12,
    color: colors.red[500],
    fontWeight: '500',
  },
  submitBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.sm,
    backgroundColor: colors.zinc[900],
    paddingVertical: spacing.lg,
    borderRadius: borderRadius.xl,
    marginTop: spacing.sm,
  },
  submitBtnDisabled: { opacity: 0.3 },
  submitBtnPressed: { opacity: 0.9 },
  submitText: { color: colors.white, fontWeight: '700', fontSize: 16 },
  hint: { textAlign: 'center', fontSize: 10, color: colors.zinc[400] },
});
