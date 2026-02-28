import React from 'react';
import { View, Text, TextInput, ScrollView, Pressable, StyleSheet } from 'react-native';
import { ArrowLeft } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../../theme';

interface AddClientFormProps {
  onBack: () => void;
  onSubmit: (data: { name: string; email: string; phone: string; city: string; type: 'propio' | 'dateado' }) => void;
}

export function AddClientForm({ onBack, onSubmit }: AddClientFormProps) {
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [phone, setPhone] = React.useState('');
  const [city, setCity] = React.useState('');
  const [type, setType] = React.useState<'propio' | 'dateado'>('propio');

  const handleSubmit = () => {
    if (!name.trim() || !phone.trim() || !city.trim()) return;
    onSubmit({ name: name.trim(), email: email.trim(), phone: phone.trim(), city: city.trim(), type });
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Pressable onPress={onBack} style={styles.backBtn}>
          <ArrowLeft size={18} color={colors.zinc[900]} />
        </Pressable>
        <Text style={styles.title}>Nuevo Cliente</Text>
      </View>
      <View style={styles.form}>
        <Text style={styles.label}>Nombre Completo</Text>
        <TextInput
          style={styles.input}
          placeholder="Ej. Juan Pérez"
          placeholderTextColor={colors.zinc[400]}
          value={name}
          onChangeText={setName}
        />
        <Text style={styles.label}>Teléfono</Text>
        <TextInput
          style={styles.input}
          placeholder="+51..."
          placeholderTextColor={colors.zinc[400]}
          value={phone}
          onChangeText={setPhone}
          keyboardType="phone-pad"
        />
        <Text style={styles.label}>Ciudad</Text>
        <TextInput
          style={styles.input}
          placeholder="Ej. Lima"
          placeholderTextColor={colors.zinc[400]}
          value={city}
          onChangeText={setCity}
        />
        <Text style={styles.label}>Email (Opcional)</Text>
        <TextInput
          style={styles.input}
          placeholder="juan@mail.com"
          placeholderTextColor={colors.zinc[400]}
          value={email}
          onChangeText={setEmail}
          keyboardType="email-address"
        />
        <Text style={styles.label}>Tipo</Text>
        <View style={styles.typeRow}>
          <Pressable onPress={() => setType('propio')} style={[styles.typeBtn, type === 'propio' && styles.typeBtnActive]}>
            <Text style={[styles.typeBtnText, type === 'propio' && styles.typeBtnTextActive]}>Propio</Text>
          </Pressable>
          <Pressable onPress={() => setType('dateado')} style={[styles.typeBtn, type === 'dateado' && styles.typeBtnActive]}>
            <Text style={[styles.typeBtnText, type === 'dateado' && styles.typeBtnTextActive]}>Dateado</Text>
          </Pressable>
        </View>
        <Pressable onPress={handleSubmit} style={styles.submitBtn}>
          <Text style={styles.submitText}>Guardar Registro</Text>
        </Pressable>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { padding: spacing.lg, gap: spacing.lg },
  header: { flexDirection: 'row', alignItems: 'center', gap: spacing.lg },
  backBtn: { padding: 6, backgroundColor: colors.white, borderWidth: 1, borderColor: colors.zinc[100], borderRadius: borderRadius.sm },
  title: { fontSize: 18, fontWeight: '700', color: colors.zinc[900] },
  form: { backgroundColor: colors.white, padding: spacing.lg, borderRadius: borderRadius.xl, borderWidth: 1, borderColor: colors.zinc[100], gap: spacing.md },
  label: { fontSize: 9, fontWeight: '700', color: colors.zinc[400], letterSpacing: 1, marginLeft: 4 },
  input: {
    backgroundColor: colors.zinc[50],
    borderWidth: 1,
    borderColor: colors.zinc[200],
    borderRadius: borderRadius.sm,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    fontSize: 12,
  },
  typeRow: { flexDirection: 'row', gap: spacing.sm },
  typeBtn: { flex: 1, paddingVertical: spacing.sm, borderRadius: borderRadius.sm, backgroundColor: colors.zinc[50], alignItems: 'center' },
  typeBtnActive: { backgroundColor: colors.emerald[500] },
  typeBtnText: { fontSize: 12, fontWeight: '600', color: colors.zinc[600] },
  typeBtnTextActive: { color: colors.white },
  submitBtn: { backgroundColor: colors.emerald[500], paddingVertical: spacing.md, borderRadius: borderRadius.xl, alignItems: 'center' },
  submitText: { color: colors.white, fontWeight: '700', fontSize: 14 },
});
